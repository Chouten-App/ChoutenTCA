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
}
