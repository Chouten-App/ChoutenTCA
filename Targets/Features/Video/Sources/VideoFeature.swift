//
//  SearchFeature.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import RelayClient
import SharedModels
import SwiftUI

@Reducer
public struct VideoFeature: Reducer {
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    public struct State: FeatureState {
        public var videoData: VideoData?
        public var status: VideoStatus = .idle
        public init() { }
    }

    public enum VideoStatus: Equatable, Sendable {
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
            case onAppear(_ url: String)
            case getServers(_ url: String)
            case setServers(_ data: [ServerList])
            case getSources(_ url: String)
            case setSources(_ data: VideoData)
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
              state.status = .loading
              return .send(.view(.getServers(url)))
          case .getServers(let url):
              return .merge(
                  .run { send in
                      do {
                          let servers = try await relayClient.servers(url)
                          await send(.view(.setServers(servers)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .setServers(let data):
              print(data)
              if let firstServerList = data.first,
                 let firstServer = firstServerList.list.first {
                  let serverUrl = firstServer.url
                  return .send(.view(.getSources(serverUrl)))
              }
              return .none
          case .getSources(let url):
              return .merge(
                  .run { send in
                      do {
                          print("running source code.")
                          let sources = try await relayClient.sources(url)
                          await send(.view(.setSources(sources)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .setSources(let data):
              state.videoData = data
              state.status = .success
              return .none
          }
        }
      }
    }
}
