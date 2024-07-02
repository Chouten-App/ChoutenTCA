//
//  AppFeature.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import Combine
import DataClient
import RepoClient
import SharedModels
import SwiftUI

@Reducer
public struct AppFeature: Reducer {
    @Dependency(\.dataClient) var dataClient
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
}
