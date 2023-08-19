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
        var hasCookies: Bool = false
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
        case requestHtml(TaskResult<String>)
        case setOverlay(data: ModuleCookies?)
        
        case parseResult(data: String)
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
                    .send(.webview(.setJsString(newString: "")))
                )
            case .setNextUrl(let newValue):
                state.nextUrl = newValue
                return .none
            case .setHomeData(let data):
                state.homeData = data
                globalData.setHomeData(data)
                return .none
            case .onAppear:
                state.htmlString = ""
                if globalData.getHomeData().count > 0 {
                    return .none
                }
                
                globalData.setInfoData(nil)
                let module = globalData.getModule()
                
                if module != nil {
                    
                    // get search js file data
                    do {
                        state.jsString = try moduleManager.getJsForType("home", 0) ?? ""
                    } catch let error {
                        print(error)
                        let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                        NotificationCenter.default
                            .post(name: NSNotification.Name("floaty"),
                                  object: nil, userInfo: data)
                    }
                    
                    return .task {
                        await .requestHtml(
                            TaskResult {
                                return """
                                <!DOCTYPE html>
                                <html lang="en">
                                <head>
                                    <meta charset="UTF-8">
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                    <title>Document</title>
                                </head>
                                <body>
                                    
                                </body>
                                </html>
                                """
                                
                                
                                /*
                                let url = URL(
                                    string: url
                                )!
                                var request = URLRequest(url: url)

                                let c_cookies = globalData.getCookies()
                                
                                if c_cookies != nil {
                                    let cookies = convertToHTTPCookies(cookies: c_cookies!.cookies)
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
                                 */
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
                
                if error as? String == "CF" {
                    state.returnData = nil
                    globalData.setShowOverlay(true)
                }
                
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(name: NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            case .setOverlay(let data):
                if let data, data.cookies.count > 0, !state.hasCookies {
                    state.hasCookies = true
                    return .send(.onAppear)
                }
                return .none
            case .parseResult(let data):
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let infoData = try decoder.decode([HomeComponent].self, from: jsonData)
                        
                        return .send(.setHomeData(data: infoData))
                    } catch {
                        print("Error decoding JSON ODSFG:", error)
                    }
                } else {
                    print("Invalid JSON string")
                }
                return .none
            }
        }
    }
}
