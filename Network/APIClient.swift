//
//  APIClient.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation
import ComposableArchitecture

private enum APIClientKey: DependencyKey {
    static let liveValue = APIClient.live
}
private enum TESTClientKey: DependencyKey {
    static let liveValue = APIClient.test
}
extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
    
    var testClient: APIClient {
        get { self[TESTClientKey.self] }
        set { self[TESTClientKey.self] = newValue }
    }
}

struct APIClient {
    var search: (_ query: String) async throws -> SearchResult
    
    struct Failure: Error {}
}

extension APIClient {
    static let live = Self(
        search: { query in
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "https://api.consumet.org/meta/anilist/\(query)")!)
            let searchResults = try JSONDecoder().decode(SearchResult.self, from: data)
            return searchResults
        }
    )
    
    static let test = Self(
        search: { query in
            if query.isEmpty {
                return SearchResult(currentPage: 1, hasNextPage: false, results: [])
            }
            return SearchResult.sample
        }
    )
}
