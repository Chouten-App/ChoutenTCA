//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI

public struct MoreFeature: Feature {
    public struct State: FeatureState {
        @BindingState
        public var isDownloadedOnly: Bool = false
        @BindingState
        public var isIncognito: Bool = false
        
        let versionString: String
        
        public init(versionString: String) {
            self.versionString = versionString
        }
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction, BindableAction {
            case binding(BindingAction<State>)
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<MoreFeature>

        public nonisolated init(store: StoreOf<MoreFeature>) {
            self.store = store
        }
    }

    public init() {}
}
