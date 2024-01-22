//
//  File.swift
//  
//
//  Created by Inumaki on 04.11.23.
//

import Architecture
import SwiftUI
import SharedModels
import ComposableArchitecture

public struct AppearanceFeature: Feature {
    public struct State: FeatureState {
        public static func == (lhs: AppearanceFeature.State, rhs: AppearanceFeature.State) -> Bool {
            return lhs.colorScheme == rhs.colorScheme &&
                    lhs.ambientMode == rhs.ambientMode
        }
        
        // 0: Light, 1: Dark, 2: System
        @AppStorage("colorScheme")
        public var colorScheme: Int = 2
        @AppStorage("ambientMode")
        public var ambientMode: Bool = true
        @AppStorage("dynamicInfo")
        public var dynamicInfo: Bool = true
        
        public init() {}
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {
            case setColorScheme(to: ChoutenColorScheme)
        }

        public enum DelegateAction: SendableAction {}

        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<AppearanceFeature>
        
        public nonisolated init(store: StoreOf<AppearanceFeature>) {
            self.store = store
        }
    }
    
    public init() {}
}
