//
//  SearchFeature.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import Core
import Combine
import ComposableArchitecture
import SwiftUI

@Reducer
struct SearchFeature: Reducer {
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    struct State: FeatureState {
        var query: String = ""
        var result: SearchResult?
        var status: SearchStatus = .idle
        var page: Int = 1
        var loading = false
        init() { }
    }

    enum SearchStatus: Equatable, Sendable {
        case idle
        case loading
        case success
        case error
    }

    @CasePathable
    @dynamicMemberLookup
    enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        enum ViewAction: SendableAction {
            case onAppear
            case clearResult
            case setQuery(_ value: String)
            case clearQuery
            case search
            case setResult(_ value: SearchResult)
            case paginateSearch
        }

        @CasePathable
        @dynamicMemberLookup
        enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    init() { }

    @ReducerBuilder<State, Action> var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case let .view(viewAction):
          switch viewAction {
          case .onAppear:
              return .none
          case .clearResult:
              state.result = nil
              return .none
          case .setQuery(let value):
              state.query = value
              state.result = nil
              if value.isEmpty { return .none }
              return .send(.view(.search))
          case .clearQuery:
              state.query = ""
              state.status = .idle
              return .none
          case .search:
              state.status = .loading
              let query = state.query
              let page = state.page
              return .merge(
                  .run { send in
                      do {
                          let result = try await relayClient.search(url: query, page: page)
                          await send(.view(.setResult(result)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .setResult(let value):
              // swiftlint:disable force_unwrapping
              guard state.result != nil,
                    !state.result!.results.isEmpty else {
                  state.result = value
                  state.status = .success

                  return .none
              }
              state.result!.results += value.results
              // swiftlint:enable force_unwrapping
              state.status = .success
              state.loading = false
              return .none
          case .paginateSearch:
              guard let resultInfo = state.result?.info,
                    state.page < resultInfo.pages else {
                  return .none
              }
              if !state.loading {
                  state.page += 1
                  state.loading = true

                  return .send(.view(.search))
              }
              return .none
          }
        }
      }
    }
}
