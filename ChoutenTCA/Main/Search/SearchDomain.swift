//
//  SearchDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation
import ComposableArchitecture

enum DataLoadingStatus {
    case notStarted
    case loading
    case success
    case error
}

struct SearchDomain: ReducerProtocol {
    struct State: Equatable {
        var loadingStatus: DataLoadingStatus = .notStarted
        
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
        case setLoadingStatus(status: DataLoadingStatus)
        
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
        
        case parseResult(data: String)
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
            case .setLoadingStatus(let status):
                state.loadingStatus = status
                return .none
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
                
                if query.isEmpty {
                    return .send(.setLoadingStatus(status: .notStarted))
                }
                
                state.htmlString = ""
                state.loadingStatus = .loading
                
                // get search code.js data
                if query.isEmpty {
                    state.searchResult = []
                    return .none
                }
                let module = globalData.getModule()
                
                if module != nil {
                    state.searchResult = []
                    
                    // get search js file data
                    do {
                        state.jsString = try moduleManager.getJsForType("search", 0)
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
                state.htmlString = html
                
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
                return .send(.setLoadingStatus(status: .error))
            case .setDownloadedOnly(let newValue):
                state.isDownloadedOnly = newValue
                return .none
            case .onAppear:
                state.loadingStatus = .notStarted
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
                if results.count > 0 {
                    return .send(.setLoadingStatus(status: .success))
                }
                return .send(.setLoadingStatus(status: .notStarted))
            case .webview:
                return .none
            case .info:
                return .none
            case .resetInfoData:
                globalData.setInfoData(nil)
                return .none
            case .parseResult(let data):
                if let jsonData = data.data(using: .utf8) {
                    do {
                        let decoder = JSONDecoder()
                        let searchResult = try decoder.decode([SearchData].self, from: jsonData)
                        
                        print("Decoded search result:", searchResult)
                        return .send(.setSearchResult(results: searchResult))
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
