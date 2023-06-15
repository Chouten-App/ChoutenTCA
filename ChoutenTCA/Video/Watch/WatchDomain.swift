//
//  WatchDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import Foundation
import ComposableArchitecture

struct WatchDomain: ReducerProtocol {
    struct State: Equatable {
        var htmlString: String = ""
        var jsString: String = ""
        var currentJsIndex: Int = 0
        var returnData: ReturnedData? = nil
        var nextUrl: String? = nil
        var infoData: InfoData? = nil
        
        var videoData: VideoData? = nil
        
        var webviewState = WebviewDomain.State()
    }
    
    enum Action: Equatable {
        case webview(WebviewDomain.Action)
        
        case onAppear(url: String)
        case onChange(url: String)
        case requestHtml(TaskResult<String>)
        case resetWebview(url: String)
        case resetWebviewChange(url: String)
        case setNextUrl(newValue: String?)
        
        case setVideoData(newValue: VideoData?)
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
            case .webview:
                return .none
            case .setVideoData(let newValue):
                state.videoData = newValue
                return .none
            case .onAppear(let infoUrl):
                state.htmlString = ""
                let module = globalData.getModule()
                state.infoData = globalData.getInfoData()
                if module != nil {
                    print(infoUrl)
                    state.htmlString = ""
                    
                    // get search js file data
                    if state.returnData == nil {
                        do {
                            state.returnData = try moduleManager.getJsForType("media", state.currentJsIndex)
                        } catch let error {
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    }
                    
                    if state.returnData != nil {
                        state.jsString = state.returnData!.js
                        print(state.jsString)
                        return .merge(
                            .run { send in
                                let videoData = globalData.observeVideoData()
                                for await value in videoData {
                                    await send(.setVideoData(newValue: value))
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
                            state.returnData = try moduleManager.getJsForType("media", state.currentJsIndex)
                        } catch let error {
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name:           NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    }
                    
                    if state.returnData != nil {
                        state.jsString = state.returnData!.js
                        print(state.returnData)
                        
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
                    
                    print("IMPORTS: \(state.returnData)")
                    
                    if !state.returnData!.imports.isEmpty {
                        var scripts = ""
                        
                        for imp in state.returnData!.imports {
                            scripts.append("<script src=\"\(imp)\"></script>")
                        }
                        
                        state.htmlString = """
                        <!DOCTYPE html>
                          <html>
                            <head>
                              <title>My Web Page</title>
                              \(scripts)
                            </head>
                            <body>
                                <div id=\"json-result\" data-json=\"\(cleaned)\">UNRELATED</div>
                            </body>
                          </html>
                        """
                    } else {
                        state.htmlString = "<div id=\"json-result\" data-json=\"\(cleaned)\">UNRELATED</div>"
                    }
                } else {
                    state.htmlString = html
                }
                return .merge(
                    .send(.webview(.setRequestType(type: "media"))),
                    .send(.webview(.setHtmlString(newString: state.htmlString))),
                    .send(.webview(.setJsString(newString: state.jsString)))
                )
            case .requestHtml(.failure(let error)):
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(name: NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            case .setNextUrl(let newValue):
                state.nextUrl = newValue
                return .none
            case .resetWebview(let url):
                return .merge(
                    .send(.webview(.setGlobalNextUrl(url: nil))),
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.onAppear(url: url))
                )
            case .resetWebviewChange(let url):
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.onChange(url: url))
                )
            }
        }
    }
}
