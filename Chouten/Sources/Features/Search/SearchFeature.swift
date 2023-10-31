//
//  File.swift
//  
//
//  Created by Inumaki on 14.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI
import SharedModels
import ViewComponents
import OSLog
import Webview
import Info

public struct SearchFeature: Feature {
    let logger = Logger(subsystem: "com.inumaki.Chouten", category: "Search")
    
    public struct State: FeatureState {
        public var webviewState: WebviewFeature.State
        public var info: InfoFeature.State
        
        @BindingState
        var query: String
        public var lastQuery: String = ""
        
        public var htmlString = ""
        public var jsString = ""
        
        public var searchResults: [SearchData] = []
        public var searchLoadable: Loadable<[SearchData]> = .pending
        
        public var state: LoadingStatus = .notStarted
        public var itemOpacity: Double = 0.8
        public var scrollPosition: CGPoint = .zero
        
        public var infoVisible: Bool = false
        public var dragState = CGSize.zero
        
        public init() {
            self.query = ""
            self.webviewState = WebviewFeature.State(htmlString: "", javaScript: "")
            self.info = InfoFeature.State(url: "")
        }
    }
    
    @Dependency(\.moduleClient) var moduleClient
    
    public enum LoadingStatus: Sendable {
        case notStarted
        case loading
        case success
        case error
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction, BindableAction {
            case search
            case resetWebview
            case setItemOpacity(value: Double)
            case backButtonPressed
            case setScrollPosition(_ value: CGPoint)
            case setLoadingStatus(_ status: LoadingStatus)
            case setSearchData(_ data: [SearchData])
            case parseResult(data: String)
            case setInfo(_ url: String)
            case setInfoVisible(_ value: Bool)
            case setDragState(_ value: CGSize)
            
            case binding(BindingAction<State>)
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {
            case webview(WebviewFeature.Action)
            case info(InfoFeature.Action)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<SearchFeature>
        //@Environment(\.namespace) var animation
        let animation: Namespace.ID
        
        public func headerOpacity(scrollPosition: CGPoint) -> CGFloat {
            if scrollPosition.y < -90 { return 1.0 }
            
            return (scrollPosition.y / CGFloat(-90))
        }
        
        public init(store: StoreOf<SearchFeature>, animation: Namespace.ID) {
            self.store = store
            self.animation = animation
        }
        
        public nonisolated init(store: StoreOf<SearchFeature>) {
            self.store = store
            self.animation = Namespace().wrappedValue
        }
    }

    public init() {}
}
