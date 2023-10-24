//
//  DiscoverFeature.swift
//
//
//  Created by Inumaki on 12.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI
import Search
import ModuleClient

public struct DiscoverFeature: Feature {
    public struct State: FeatureState {
        public var search: SearchFeature.State
        
        public var state: LoadingStatus = .success
        public var searchVisible: Bool = false
        
        //@BindingState
        public var carouselIndex: Int = 0
        public var scrollPosition: CGPoint = .zero
        
        public init() {
            self.search = SearchFeature.State()
        }
    }
    
    public enum LoadingStatus: Sendable {
        case notStarted
        case loading
        case success
        case error
    }
    
    @Dependency(\.moduleClient)
    var moduleClient
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction, BindableAction {
            case onAppear
            case setState(newState: LoadingStatus)
            case setSearchVisible(newValue: Bool)
            case setCarouselIndex(value: Int)
            case setScrollPosition(_ value: CGPoint)
            case refresh
            
            case binding(BindingAction<State>)
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {
            case search(SearchFeature.Action)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<DiscoverFeature>
        @Namespace var animation
        
        public func refreshPercentage(scrollPosition: CGPoint) -> CGFloat {
            if scrollPosition.y > 170 { return 1.0 }
            
            return (scrollPosition.y / CGFloat(170))
        }

        public nonisolated init(store: StoreOf<DiscoverFeature>) {
            self.store = store
        }
    }

    public init() {}
}
