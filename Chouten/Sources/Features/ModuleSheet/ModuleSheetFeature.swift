//
//  File.swift
//  
//
//  Created by Inumaki on 19.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI
import ModuleClient
import OSLog

public struct ModuleSheetFeature: Feature {
    let logger = Logger(subsystem: "com.inumaki.Chouten", category: "ModuleSheet")
    
    public struct State: FeatureState {
        public var offset: Double = 0.0
        public var tempOffset: Double = 0.0
        public var contentHeight: Double = 0.0
        
        public var animate: Bool = false
        
        public var availableModules: [Module] = []
        
        public init() {}
    }
    
    @Dependency(\.moduleClient) var moduleClient
    
    public enum LoadingStatus: Sendable {
        case notStarted
        case loading
        case success
        case error
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {
            case setContentHeight(newHeight: Double) 
            case setOffset(value: Double)
            case setOffsetAndTemp(value: Double)
            case updateOffset(value: Double)
            case setTempOffset(value: Double)
            case updateTempOffset(value: Double)
            case setAnimate(_ value: Bool)
            
            case onAppear
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<ModuleSheetFeature>
        
        @GestureState var gestureOffset: CGFloat = 0
        let minimum: CGFloat = 50
        
        @MainActor
        func onChange(offset: Double, lastOffset: Double) -> Double? {
            if offset < 32 {
                return gestureOffset + lastOffset
            }
            return nil
        }

        public nonisolated init(store: StoreOf<ModuleSheetFeature>) {
            self.store = store
        }
    }

    public init() {}
}
