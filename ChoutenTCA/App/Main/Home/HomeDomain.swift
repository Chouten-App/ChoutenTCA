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
        case fetchHomedata
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
                    .send(.fetchHomedata)
                )
            case .resetWebviewChange(_):
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: "")))
                )
            case .setNextUrl(let newValue):
                state.nextUrl = newValue
                return .none
            case .setHomeData(let data):
                state.homeData = data
                if state.homeData.count == 0 {
                    return .send(.resetWebview)
                }
                //globalData.setHomeData(data)
                return .none
            case .fetchHomedata:
                if state.homeData.count > 0 {
                    return .none
                }
                
                state.htmlString = ""
                
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
                    
                    state.htmlString = """
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
                    return .merge(
                        .send(.webview(.setRequestType(type: "home"))),
                        .send(.webview(.setHtmlString(newString: state.htmlString))),
                        .send(.webview(.setJsString(newString: state.jsString)))
                    )
                }
                return .none
            case .onAppear:
                return .merge(
                    .run { send in
                        let homeData = globalData.observeHomeData()
                        for await value in homeData {
                            await send(.setHomeData(data: value))
                        }
                    },
                    .send(.resetWebview)
                )
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
