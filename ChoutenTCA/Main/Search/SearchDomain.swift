//
//  SearchDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation
import ComposableArchitecture

struct SearchDomain: ReducerProtocol {
    struct State: Equatable {
        var query: String = ""
        var htmlString: String? = nil
        var jsString: String? = nil
        var returnData: ReturnedData? = nil
        
        var loading: Bool = false
        var showOverlay: Bool = false
        
        var webviewState = WebviewDomain.State()
        var infoState = InfoDomain.State()
        
        var searchResult: [SearchData] = []
        
        var isDownloadedOnly: Bool = false
        
        /*var results: [SearchData] {
            searchResult != nil
            ? searchResult!.results
            : []
        }*/
    }
    
    enum Action: Equatable {
        case setQuery(query: String)
        case search
        case webview(WebviewDomain.Action)
        case info(InfoDomain.Action)
        case setLoading(newLoading: Bool)
        case setSearchResult(results: [SearchData])
        
        case setDownloadedOnly(newValue: Bool)
        case onAppear
        
        case requestHtml(TaskResult<String>)
        
        case resetWebview
        case resetInfoData
        case resetSearch
    }
    
    @Dependency(\.moduleManager)
    var moduleManager
    
    @Dependency(\.globalData)
    var globalData
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \.webviewState, action: /Action.webview) {
            WebviewDomain()
        }
        
        Scope(state: \.infoState, action: /Action.info) {
            InfoDomain()
        }
        
        Reduce { state, action in
            switch action {
            case .setQuery(let query):
                state.query = query
                return .none
            case .resetWebview:
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.search)
                )
            case .resetSearch:
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.setQuery(query: "")),
                    .send(.setSearchResult(results: []))
                )
            case .search:
                let query = state.query
                state.htmlString = ""
                state.loading = true
                
                // get search code.js data
                if query.isEmpty {
                    state.searchResult = []
                    return .none
                }
                let module = globalData.getModule()
                
                if module != nil {
                    state.searchResult = []
                    
                    // get search js file data
                    if state.returnData == nil {
                        do {
                            state.returnData = try moduleManager.getJsForType("search", 0)
                        } catch let error {
                            print(error)
                            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                            NotificationCenter.default
                                .post(name: NSNotification.Name("floaty"),
                                      object: nil, userInfo: data)
                        }
                    }
                    
                    if state.returnData != nil {
                        state.jsString = state.returnData!.js
                        
                        if state.returnData!.request == nil {
                            return .none
                        }
                        let url = state.returnData!.request!.url
                            .replacingOccurrences(of: "<query>", with: query)
                            .replacingOccurrences(of: " ", with: state.returnData!.separator.isEmpty ? "%20" : state.returnData!.separator)
                            .replacingOccurrences(of: "’", with: "")
                            .replacingOccurrences(of: ",", with: "")
                        
                        print(url)
                        
                        return .task {
                            await .requestHtml(
                                TaskResult {
                                    let url = URL(
                                        string: url
                                    )!
                                    var request = URLRequest(url: url)

                                    let c_cookies = globalData.getCookies()

                                    print(c_cookies)
                                    
                                    /*if c_cookies != nil {
                                        let cookies = convertToHTTPCookies(cookies: c_cookies!.cookies)
                                        
                                        print(cookies)
                                        
                                        let headerFields = HTTPCookie.requestHeaderFields(with: cookies)
                                        for (field, value) in headerFields {
                                            request.addValue(value, forHTTPHeaderField: field)
                                        }
                                        
                                        
                                    }
                                     */
                                    
                                    let userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"
                                    request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
                                    
                                    request.setValue("cf_clearance=v9VkTW72jt0qb1PiO2fXPuOldU.RZU3QbECQAi0MD1U-1688608961-0-160; _ga_NCRY038TTP=GS1.1.1688607035.2.1.1688610466.0.0.0", forHTTPHeaderField: "Cookie")
                                    
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
                    .send(.webview(.setRequestType(type: "search"))),
                    .send(.webview(.setHtmlString(newString: state.htmlString ?? ""))),
                    .send(.webview(.setJsString(newString: state.jsString ?? "")))
                )
            case .setLoading(let newLoading):
                state.loading = newLoading
                return .none
            case .requestHtml(.failure(let error)):
                
                if error as? String == "CF" {
                    state.returnData = nil
                    globalData.setShowOverlay(true)
                }
                
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(name:           NSNotification.Name("floaty"),
                          object: nil, userInfo: data)
                return .none
            case .setDownloadedOnly(let newValue):
                state.isDownloadedOnly = newValue
                return .none
            case .onAppear:
                state.isDownloadedOnly = globalData.getDownloadedOnly()
                state.searchResult = globalData.getSearchResults()
                globalData.setInfoData(nil)
                return .merge(
                    .run { send in
                        let downloadedOnly = globalData.observeDownloadedOnly()
                        for await value in downloadedOnly {
                            await send(.setDownloadedOnly(newValue: value))
                        }
                    },
                    .run { send in
                        let searchResults = globalData.observeSearchResults()
                        for await value in searchResults {
                            await send(.setSearchResult(results: value))
                        }
                    }
                )
            case .setSearchResult(let results):
                state.searchResult = results
                return .send(.setLoading(newLoading: false))
            case .webview:
                return .none
            case .info:
                return .none
            case .resetInfoData:
                globalData.setInfoData(nil)
                return .none
            }
        }
    }
}
