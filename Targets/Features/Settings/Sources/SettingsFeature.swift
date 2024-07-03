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

//@Reducer
//public struct SettingsFeature: Reducer {
//    @Dependency(\.relayClient) var relayClient
//
//    @ObservableState
//    public struct State: FeatureState {
//        public init() { }
//    }
//
//    @CasePathable
//    @dynamicMemberLookup
//    public enum Action: FeatureAction {
//        @CasePathable
//        @dynamicMemberLookup
//        public enum ViewAction: SendableAction {
//            case onAppear
//        }
//
//        @CasePathable
//        @dynamicMemberLookup
//        public enum DelegateAction: SendableAction {}
//
//        @CasePathable
//        @dynamicMemberLookup
//        public enum InternalAction: SendableAction {}
//
//        case view(ViewAction)
//        case delegate(DelegateAction)
//        case `internal`(InternalAction)
//    }
//
//    public init() { }
//}
