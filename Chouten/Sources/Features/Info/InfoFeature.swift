//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI
import SharedModels
import Webview

public struct InfoFeature: Feature {
    public struct State: FeatureState {
        public let url: String
        public var webviewState: WebviewFeature.State
        
        public var state: LoadingStatus = .success
        
        public var backgroundColor: UIColor = .black
        public var textColor: UIColor = .white
        
        public var infoData: InfoData = InfoData.sample
        
        public init(url: String) {
            self.url = url
            self.webviewState = WebviewFeature.State(htmlString: "", javaScript: "")
        }
    }
    
    public enum LoadingStatus: Sendable {
        case notStarted
        case loading
        case success
        case error
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {
            case setBackgroundColor(color: UIColor)
            case setTextColor(color: UIColor)
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {
            case webview(WebviewFeature.Action)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<InfoFeature>
        
        public nonisolated init(store: StoreOf<InfoFeature>) {
            self.store = store
        }
    }

    public init() {}
}
