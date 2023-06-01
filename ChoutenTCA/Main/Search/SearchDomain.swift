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
            case .search:
                let query = state.query
                state.htmlString = ""
                
                // get search code.js data
                if query.isEmpty {
                    state.searchResult = []
                    return .none
                }
                let module = globalData.getModule()
                print(module)
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
                            .replacingOccurrences(of: "<query>", with: query.replacingOccurrences(of: " ", with: "%20"))
                            .replacingOccurrences(of: "’", with: "")
                            .replacingOccurrences(of: ",", with: "")
                        
                        return .task {
                            await .requestHtml(
                                TaskResult {
                                    let (data, response) = try await URLSession.shared.data(
                                        from: URL(
                                            string: url
                                        )!
                                    )
                                    guard let httpResponse = response as? HTTPURLResponse,
                                            httpResponse.statusCode == 200,
                                            let html = String(data: data, encoding: .utf8) else {
                                        throw "Failed to load data from \(url)"
                                    }
                                    return html
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
                return .none
            case .webview:
                return .none
            case .info:
                return .none
            }
        }
    }
}
