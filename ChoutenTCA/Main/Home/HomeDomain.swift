//
//  HomeDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import Foundation
import ComposableArchitecture

struct HomeDomain: ReducerProtocol {
    struct State: Equatable {
        var carouselIndex: Int = 0
        var htmlString: String = ""
        var jsString: String = ""
        var currentJsIndex: Int = 0
        var returnData: ReturnedData? = nil
        var nextUrl: String? = nil
        
        var homeData: [HomeComponent] = []
        
        var webviewState = WebviewDomain.State()
        var infoState = InfoDomain.State()
        
    }
    
    enum Action: Equatable {
        case setCarouselIndex(newIndex: Int)
        case webview(WebviewDomain.Action)
        case info(InfoDomain.Action)
        
        case setHomeData(data: [HomeComponent])
        
        case resetWebview
        case resetWebviewChange(url: String)
        case onAppear
        case setNextUrl(newValue: String?)
        case onChange(url: String)
        case requestHtml(TaskResult<String>)
    }
    
    @Dependency(\.globalData)
    var globalData
    
    @Dependency(\.moduleManager)
    var moduleManager
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.webviewState, action: /Action.webview) {
            WebviewDomain()
        }
        
        Scope(state: \.infoState, action: /Action.info) {
            InfoDomain()
        }
        
        Reduce { state, action in
            switch action {
            case .setCarouselIndex(let newIndex):
                state.carouselIndex = newIndex
                return .none
            case .webview:
                return .none
            case .info:
                return .none
            case .resetWebview:
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.onAppear)
                )
            case .resetWebviewChange(let url):
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.onChange(url: url))
                )
            case .setNextUrl(let newValue):
                state.nextUrl = newValue
                return .none
            case .setHomeData(let data):
                state.homeData = data
                return .none
            case .onAppear:
                state.htmlString = ""
                let module = globalData.getModule()
                if module != nil {
                    state.htmlString = ""
                    
                    // get search js file data
                    if state.returnData == nil {
                        do {
                            state.returnData = try moduleManager.getJsForType("home", state.currentJsIndex)
                        } catch let error {
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    }
                    
                    if state.returnData != nil {
                        state.jsString = state.returnData!.js
                        
                        if state.returnData!.request != nil {
                            let requestUrl = state.returnData!.request!.url
                            
                            return .merge(
                                .run { send in
                                    let homeData = globalData.observeHomeData()
                                    for await value in homeData {
                                        await send(.setHomeData(data: value))
                                    }
                                },
                                .run { send in
                                    let nextUrl = globalData.observeNextUrl()
                                    for await value in nextUrl {
                                        await send(.setNextUrl(newValue: value))
                                    }
                                },
                                .task {
                                    await .requestHtml(
                                        TaskResult {
                                            let (data, response) = try await URLSession.shared.data(
                                                from: URL(
                                                    string: requestUrl
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
            case .onChange(let infoUrl):
                state.returnData = nil
                if state.currentJsIndex == 0 {
                    state.currentJsIndex = 2
                } else {
                    state.currentJsIndex += 1
                }
                
                state.htmlString = ""
                let module = globalData.getModule()
                if module != nil {
                    print(infoUrl)
                    state.htmlString = ""
                    
                    // get search js file data
                    if state.returnData == nil {
                        do {
                            state.returnData = try moduleManager.getJsForType("home", state.currentJsIndex)
                        } catch let error {
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    }
                    
                    if state.returnData != nil {
                        state.jsString = state.returnData!.js
                        
                        return .merge(
                            .run { send in
                                let nextUrl = globalData.observeNextUrl()
                                for await value in nextUrl {
                                    await send(.setNextUrl(newValue: value))
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
                                            throw "Failed to load data from \(infoUrl)"
                                        }
                                        return html
                                    }
                                )
                            }
                        )
                    }
                }
                return .none
            case .requestHtml(.success(let html)):
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
                    .send(.webview(.setRequestType(type: "home"))),
                    .send(.webview(.setHtmlString(newString: state.htmlString))),
                    .send(.webview(.setJsString(newString: state.jsString)))
                )
            case .requestHtml(.failure(let error)):
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(name: NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            }
        }
    }
}
