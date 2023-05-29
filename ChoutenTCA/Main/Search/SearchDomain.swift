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
        var searchResult: SearchResult? = nil
        
        var isDownloadedOnly: Bool = false
        
        var results: [SearchData] {
            searchResult != nil
            ? searchResult!.results
            : []
        }
    }
    
    enum Action: Equatable {
        case setQuery(query: String)
        case search
        case searchResult(TaskResult<SearchResult>)
        
        case setDownloadedOnly(newValue: Bool)
        case onAppear
    }
    
    @Dependency(\.apiClient)
    var client
    
    @Dependency(\.globalData)
    var globalData
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setQuery(let query):
            state.query = query
            return .none
        case .search:
            let query = state.query
            return .task {
                await .searchResult(
                    TaskResult {
                        try await client.search(query)
                    }
                )
            }
        case .searchResult(.success(let searchResult)):
            state.searchResult = searchResult
            return .none
        case .searchResult(.failure(let error)):
            print(error)
            // SHOW SNACKBAR
            return .none
        case .setDownloadedOnly(let newValue):
            state.isDownloadedOnly = newValue
            return .none
        case .onAppear:
            state.isDownloadedOnly = globalData.getDownloadedOnly()
            return .run { send in
                let downloadedOnly = globalData.observeDownloadedOnly()
                for await value in downloadedOnly {
                    await send(.setDownloadedOnly(newValue: value))
                }
            }
        }
    }
}
