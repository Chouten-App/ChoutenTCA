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
}
