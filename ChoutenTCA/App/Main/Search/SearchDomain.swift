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
        var oldQuery: String = ""
        var htmlString: String? = nil
        var jsString: String? = nil
        var returnData: ReturnedData? = nil
        
        var loading: Bool = false
        var showOverlay: Bool = false
        
        var webviewState = WebviewDomain.State()
        var infoState = InfoDomain.State()
        
        var searchResult: [SearchData] = []
        
        var isDownloadedOnly: Bool = false
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
                state.loadingStatus = .notStarted
                state.searchResult = []
                globalData.setSearchResults([])
                let query = state.query
                
                if query.isEmpty {
                    return .none
                }
                
                state.oldQuery = query
                
                state.htmlString = ""
                state.loadingStatus = .loading
                
                let module = globalData.getModule()
                
                if module != nil {
                    //print(module?.name)
                    
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
                        .send(.webview(.setRequestType(type: "search"))),
                        .send(.webview(.setHtmlString(newString: state.htmlString ?? ""))),
                        .send(.webview(.setJsString(newString: state.jsString ?? "")))
                    )
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
                    .post(name: NSNotification.Name("floaty"),
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
                return .merge(
                    .send(.webview(.setHtmlString(newString: ""))),
                    .send(.webview(.setJsString(newString: ""))),
                    .send(.setLoadingStatus(status: .error))
                )
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
                        globalData.setSearchResults(searchResult)
                        return .none
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
