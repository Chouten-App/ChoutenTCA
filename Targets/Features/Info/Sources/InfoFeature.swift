//
//  InfoFeature.swift
//  Info
//
//  Created by Inumaki on 25.04.24.
//

import Architecture
import Combine
import RelayClient
import SharedModels
import SwiftUI

@Reducer
public struct InfoFeature: Reducer {
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    public struct State: FeatureState {
        // swiftlint:disable redundant_optional_initialization
        public var infoData: InfoData? = nil
        // swiftlint:enable redundant_optional_initialization
        public var doneLoading = false

        public init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear(_ url: String)
            case fetchMedia(_ url: String)
            case setInfoData(_ data: InfoData)
            case setMediaList(_ data: [MediaList])
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
          case .onAppear(let url):
              return .merge(
                  .run { send in
                      do {
                          let data = try await self.relayClient.info(url)
                          print(data)
                          await send(.view(.setInfoData(data)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .fetchMedia(let url):
              return .merge(
                  .run { send in
                      do {
                          let data = try await self.relayClient.media(url)
                          print(data)
                          await send(.view(.setMediaList(data)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .setInfoData(let data):
              state.infoData = data

              if let url = data.seasons.first(where: { $0.selected == true })?.url {
                  return .send(.view(.fetchMedia(url)))
              } else if let url = data.seasons.first?.url {
                  return .send(.view(.fetchMedia(url)))
              }

              state.doneLoading = true

              return .none
          case .setMediaList(let data):
              state.infoData?.mediaList = data
              state.doneLoading = true
              return .none
          }
        }
      }
    }
}
