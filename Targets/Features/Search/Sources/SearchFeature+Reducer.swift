//
//  SearchFeature+Reducer.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import ComposableArchitecture
import SharedModels
import SwiftUI

//extension SearchFeature {
//  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
//    Reduce { state, action in
//      switch action {
//      case let .view(viewAction):
//        switch viewAction {
//        case .onAppear:
//            return .none
//        case .setQuery(let value):
//            state.query = value
//            return .send(.view(.search))
//        case .clearQuery:
//            state.query = ""
//            state.status = .idle
//            return .none
//        case .search:
//            state.status = .loading
//            let query = state.query
//            let page = state.page
//            return .merge(
//                .run { send in
//                    do {
//                        let result = try await relayClient.search(url: query, page: page)
//                        await send(.view(.setResult(result)))
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//            )
//        case .setResult(let value):
//            // swiftlint:disable force_unwrapping
//            guard state.result != nil,
//                  !state.result!.results.isEmpty else {
//                state.result = value
//                state.status = .success
//                return .none
//            }
//            state.result!.results += value.results
//            // swiftlint:enable force_unwrapping
//            state.status = .success
//            return .none
//        case .paginateSearch:
//            if !state.loading {
//                state.page += 1
//                state.loading = true
//
//                return .send(.view(.search))
//            }
//            return .none
//        }
//      }
//    }
//  }
//}
