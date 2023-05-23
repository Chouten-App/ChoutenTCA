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
    }
    
    @Dependency(\.apiClient)
    var client
    
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
        }
    }
}
