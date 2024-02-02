//
//  File.swift
//  
//
//  Created by Inumaki on 14.12.23.
//

import Architecture
import SwiftUI
import ComposableArchitecture

public struct HomeFeature: Feature {
    public struct State: FeatureState {
        public init() {}
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {}
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {}
        
        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<HomeFeature>
        
        public nonisolated init(store: StoreOf<HomeFeature>) {
            self.store = store
        }
    }

    public init() {}
}

