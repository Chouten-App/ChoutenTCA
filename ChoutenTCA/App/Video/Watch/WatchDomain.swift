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
        var servers: [ServerData] = []
        
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
        case setServers(newValue: [ServerData])
        
        case parseResult(data: String)
        case parseMediaResult(data: String)
        case resetWatchpage
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
                
                if module != nil {
                    // get search js file data
                    do {
                        state.jsString = try moduleManager.getJsForType("media", 0) ?? ""
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
            case .onChange(let infoUrl):
                state.htmlString = ""
                let module = globalData.getModule()
                
                if module != nil {
                    // get search js file data
                    do {
                        state.jsString = try moduleManager.getJsForType("media", 0) ?? ""
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
                globalData.setVideoData(nil)
                globalData.setServers([])
                
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
            case .parseResult(let data):
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let servers = try decoder.decode([ServerData].self, from: jsonData)
                        
                        return .send(.setServers(newValue: servers))
                    } catch {
                        print("Error decoding JSON ODSFG:", error)
                    }
                } else {
                    print("Invalid JSON string")
                }
                return .none
            case .parseMediaResult(let data):
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let infoData = try decoder.decode(VideoData.self, from: jsonData)
                        
                        return .send(.setVideoData(newValue: infoData))
                    } catch {
                        print("Error decoding JSON ODSFG:", error)
                    }
                } else {
                    print("Invalid JSON string")
                }
                return .none
            case .setServers(let newValue):
                state.servers = newValue
                return .none
            case .resetWatchpage:
                globalData.setVideoData(nil)
                globalData.setServers([])
                state.servers = []
                return .none
            }
        }
    }
}
