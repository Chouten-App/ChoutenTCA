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
}
