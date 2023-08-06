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
        var nextUrl: String? = nil
        var selectedSeason: Int = 0
        
        var showHeader: Bool = false
        var showRealHeader: Bool = false
        
        var infoData: InfoData? = nil
        
        var webviewState = WebviewDomain.State()
        var watchState = WatchDomain.State()
    }
    
    enum Action: Equatable {
        case setToggle(newValue: Bool)
        case webview(WebviewDomain.Action)
        case watch(WatchDomain.Action)
        case onAppear(url: String)
        case onChange(url: String)
        case onDisappear
        case requestHtml(TaskResult<String>)
        case setInfoData(newValue: InfoData?)
        case setGlobalInfoData(newValue: InfoData?)
        case resetWebview(url: String)
        case resetWebviewChange(url: String)
        case setNextUrl(newValue: String?)
        case setSelectedSeason(newValue: Int)
        
        case setHeader(newBool: Bool)
        case setRealHeader(newBool: Bool)
    }
    
    @Dependency(\.globalData)
    var globalData
    
    @Dependency(\.moduleManager)
    var moduleManager
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.webviewState, action: /Action.webview) {
            WebviewDomain()
        }
        
        Scope(state: \.watchState, action: /Action.watch) {
            WatchDomain()
        }
        
        Reduce { state, action in
            switch action {
            case .setToggle(let newValue):
                state.isToggleOn = newValue
                return .none
            case .webview:
                return .none
            case .watch:
                return .none
            case .onAppear(let infoUrl):
                print(infoUrl)
                if globalData.getInfoData() != nil {
                    state.infoData = globalData.getInfoData()
                    return .none
                }
                
                state.infoData = nil
                state.returnData = nil
                state.currentJsIndex = 0
                globalData.setInfoData(nil)
                let infoData: InfoData? = nil
                if infoData == nil || (infoData!.mediaList.count == 0) {
                    state.htmlString = ""
                    let module = globalData.getModule()
                    if module != nil {
                        print(infoUrl)
                        state.htmlString = ""
                        
                        // get search js file data
                        if state.returnData == nil {
                            do {
                                state.jsString = try moduleManager.getJsForType("info", state.currentJsIndex) ?? ""
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
                                    let infoData = globalData.observeInfoData()
                                    for await value in infoData {
                                        await send(.setInfoData(newValue: value))
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
                                            let url = URL(
                                                string: infoUrl
                                            )!
                                            var request = URLRequest(url: url)

                                            let c_cookies = globalData.getCookies()

                                            print(c_cookies)
                                            
                                            if c_cookies != nil {
                                                let cookies = convertToHTTPCookies(cookies: c_cookies!.cookies)
                                                
                                                print(cookies)
                                                
                                                let headerFields = HTTPCookie.requestHeaderFields(with: cookies)
                                                for (field, value) in headerFields {
                                                    request.addValue(value, forHTTPHeaderField: field)
                                                }
                                                
                                                
                                            }
                                            
                                            let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Mobile/15E148 Safari/604.1"
                                            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                                            
                                            print(request.allHTTPHeaderFields)
                                            
                                            let (data, response) = try await URLSession.shared.data(for: request)
                                            
                                            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                                var html: String = ""
                                                print(statusCode)
                                                switch statusCode {
                                                case 200:
                                                    html = String(data: data, encoding: .utf8) ?? ""
                                                    break
                                                case 403:
                                                    // Cloudflare detected, open website in visible webview
                                                    throw "CF"
                                                case _:
                                                    throw "Failed to load data from \(url)"
                                                }
                                                return html
                                            }
                                            
                                            throw "UNKNOWN ERROR"
                                        }
                                    )
                                }
                            )
                        }
                    }
                }
                return .none
            case .onChange(let infoUrl):
                let infoData = globalData.getInfoData()
                state.returnData = nil
                if state.currentJsIndex == 0 {
                    state.currentJsIndex = 2
                } else {
                    state.currentJsIndex += 1
                }
                
                if infoData == nil || (infoData!.mediaList.count == 0) {
                    state.htmlString = ""
                    let module = globalData.getModule()
                    if module != nil {
                        print(infoUrl)
                        state.htmlString = ""
                        
                        // get search js file data
                        if state.returnData == nil {
                            do {
                                state.jsString = try moduleManager.getJsForType("info", state.currentJsIndex) ?? ""
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
                                    let infoData = globalData.observeInfoData()
                                    for await value in infoData {
                                        await send(.setInfoData(newValue: value))
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
                                            let url = URL(
                                                string: infoUrl
                                            )!
                                            var request = URLRequest(url: url)

                                            let c_cookies = globalData.getCookies()

                                            print(c_cookies)
                                            
                                            if c_cookies != nil {
                                                let cookies = convertToHTTPCookies(cookies: c_cookies!.cookies)
                                                
                                                print(cookies)
                                                
                                                let headerFields = HTTPCookie.requestHeaderFields(with: cookies)
                                                for (field, value) in headerFields {
                                                    request.addValue(value, forHTTPHeaderField: field)
                                                }
                                                
                                                
                                            }
                                            
                                            let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Mobile/15E148 Safari/604.1"
                                            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                                            
                                            print(request.allHTTPHeaderFields)
                                            
                                            let (data, response) = try await URLSession.shared.data(for: request)
                                            
                                            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                                var html: String = ""
                                                print(statusCode)
                                                switch statusCode {
                                                case 200:
                                                    html = String(data: data, encoding: .utf8) ?? ""
                                                    break
                                                case 403:
                                                    // Cloudflare detected, open website in visible webview
                                                    throw "CF"
                                                case _:
                                                    throw "Failed to load data from \(url)"
                                                }
                                                return html
                                            }
                                            
                                            throw "UNKNOWN ERROR"
                                        }
                                    )
                                }
                            )
                        }
                    }
                }
                return .none
            case .requestHtml(.success(let html)):
                print(state.returnData)
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
                    .post(name: NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            case .setInfoData(let newValue):
                state.infoData = newValue
                return .none
            case .setGlobalInfoData(let newValue):
                state.infoData = newValue
                globalData.setInfoData(newValue)
                return .none
            case .setNextUrl(let newValue):
                state.nextUrl = newValue
                return .none
            case .setHeader(let newBool):
                state.showHeader = newBool
                return .none
            case .setRealHeader(let newBool):
                state.showRealHeader = newBool
                return .none
            case .setSelectedSeason(let newValue):
                state.selectedSeason = newValue
                return .none
            case .resetWebview(let url):
                return .merge(
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
            case .onDisappear:
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: "")))
                )
            }
        }
    }
}
