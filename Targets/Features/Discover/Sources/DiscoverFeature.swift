//
//  DiscoverFeature.swift
//  Discover
//
//  Created by Inumaki on 19.04.24.
//

import Architecture
import Combine
import RelayClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct DiscoverFeature: Reducer {
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    public struct State: FeatureState {
        public var discoverSections: [DiscoverSection] = []

        public init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear
            case setDiscoverSections(_ data: [DiscoverSection])
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
