//
//  SearchFeature.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import RelayClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct SearchFeature: Reducer {
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    public struct State: FeatureState {
        public var query: String = ""
        public var result: SearchResult?
        public var status: SearchStatus = .idle
        public var page: Int = 1
        public var loading = false
        public init() { }
    }

    public enum SearchStatus: Equatable, Sendable {
        case idle
        case loading
        case success
        case error
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
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
        public enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    public init() { }

    @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
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
