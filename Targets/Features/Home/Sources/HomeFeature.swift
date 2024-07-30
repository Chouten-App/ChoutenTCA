//
//  HomeFeature.swift
//  Home
//
//  Created by Inumaki on 19.04.24.
//

import Architecture
import Combine
import DatabaseClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct HomeFeature: Reducer {
    @Dependency(\.databaseClient) var databaseClient

    @ObservableState
    public struct State: FeatureState {
        public var collections: [HomeSection] = []

        public init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear
            case setCollections(_ data: [HomeSection])
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
              state.collections = []
              return .merge(
                  .run { send in
                      do {
                          try await self.databaseClient.initDB()
                          
                          let data = try await self.databaseClient.fetchCollections();
                          
                          await send(.view(.setCollections(data)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .setCollections(let data):
              state.collections = data
              return .none
          }
        }
      }
    }
}
