//
//  AppFeature.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import Combine
import RepoClient
import SharedModels
import SwiftUI

@Reducer
public struct AppFeature: Reducer {
    @Dependency(\.repoClient) var repoClient

    @ObservableState
    public struct State: FeatureState {

        public var selected = Tab.home

        public init() { }

        public enum Tab: String, CaseIterable, Sendable {
            case home = "Home"
            case discover = "Discover"
            case repos = "Repos"

            var image: String {
                switch self {
                case .home:
                    "house"
                case .discover:
                    "safari"
                case .repos:
                    "shippingbox"
                }
            }

            var selected: String {
                switch self {
                case .home:
                    "house.fill"
                case .discover:
                    "safari.fill"
                case .repos:
                    "shippingbox.fill"
                }
            }
        }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case changeTab(_ tab: State.Tab)
            case toggleTabbar
            case onAppear
            case install(url: String)
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
          case let .changeTab(tab):
            state.selected = tab
            return .none
          case .toggleTabbar:
            return .none
          case .install(let url):
              guard let checkedUrl = URL(string: url) else {
                  return .send(.view(.onAppear))
              }

              return .merge(
                  .run { _ in
                      do {
                          try await repoClient.installRepo(checkedUrl)
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          }
        }
      }
    }
}
