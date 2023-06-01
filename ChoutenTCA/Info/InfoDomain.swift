//
//  InfoDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation
import ComposableArchitecture

struct InfoDomain: ReducerProtocol {
    struct State: Equatable {
        var isToggleOn: Bool = false
        var htmlString: String = ""
        var jsString: String = ""
        var currentJsIndex: Int = 0
        var returnData: ReturnedData? = nil
        
        var infoData: InfoData? = nil
        
        var webviewState = WebviewDomain.State()
    }
    
    enum Action: Equatable {
        case setToggle(newValue: Bool)
        case webview(WebviewDomain.Action)
        case onAppear(url: String)
        case requestHtml(TaskResult<String>)
        case setInfoData(newValue: InfoData?)
    }
    
    @Dependency(\.globalData)
    var globalData
    
    @Dependency(\.moduleManager)
    var moduleManager
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.webviewState, action: /Action.webview) {
            WebviewDomain()
        }
        
        Reduce { state, action in
            switch action {
            case .setToggle(let newValue):
                state.isToggleOn = newValue
                return .none
            case .webview:
                return .none
            case .onAppear(let infoUrl):
                let infoData = globalData.getInfoData()
                print(infoData)
                if infoData == nil || (infoData!.mediaList.count > 0 && infoData!.mediaList[0].count == 0) {
                    state.htmlString = ""
                    let module = globalData.getModule()
                    if module != nil {
                        state.htmlString = ""
                        
                        // get search js file data
                        if state.returnData == nil {
                            do {
                                state.returnData = try moduleManager.getJsForType("info", state.currentJsIndex)
                            } catch let error {
                                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                                NotificationCenter.default
                                    .post(name:           NSNotification.Name("floaty"),
                                          object: nil, userInfo: data)
                            }
                        }
                        
                        if state.returnData != nil {
                            state.jsString = state.returnData!.js
                            
                            var url = ""
                            
                            let requestUrl = url
                            
                            return .merge(
                                .run { send in
                                    let infoData = globalData.observeInfoData()
                                    for await value in infoData {
                                        await send(.setInfoData(newValue: value))
                                    }
                                },
                                .task {
                                    await .requestHtml(
                                        TaskResult {
                                            let (data, response) = try await URLSession.shared.data(
                                                from: URL(
                                                    string: infoUrl
                                                )!
                                            )
                                            guard let httpResponse = response as? HTTPURLResponse,
                                                    httpResponse.statusCode == 200,
                                                    let html = String(data: data, encoding: .utf8) else {
                                                throw "Failed to load data from \(requestUrl)"
                                            }
                                            return html
                                        }
                                    )
                                }
                            )
                        }
                    }
                }
                return .none
            case .requestHtml(.success(let html)):
                print(html)
                if state.returnData != nil && state.returnData!.usesApi {
                    let regexPattern = "&#\\d+;"
                    let regex = try! NSRegularExpression(pattern: regexPattern)
                    
                    let range = NSRange(html.startIndex..., in: html)
                    
                    let modifiedString = regex.stringByReplacingMatches(in: html, options: [], range: range, withTemplate: "")
                    
                    let cleaned = modifiedString.replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "\"", with: "'")
                    
                    state.htmlString = "<div id=\"json-result\" data-json=\"\(cleaned)\">UNRELATED</div>"
                } else {
                    state.htmlString = html
                }
                return .merge(
                    .send(.webview(.setRequestType(type: "info"))),
                    .send(.webview(.setHtmlString(newString: state.htmlString))),
                    .send(.webview(.setJsString(newString: state.jsString)))
                )
            case .requestHtml(.failure(let error)):
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(name:           NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            case .setInfoData(let newValue):
                state.infoData = newValue
                return .none
            }
        }
    }
}
