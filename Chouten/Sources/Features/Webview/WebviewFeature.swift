//
//  File.swift
//  
//
//  Created by Inumaki on 20.10.23.
//

import Foundation
import ComposableArchitecture
import Architecture
import SwiftUI

public struct WebviewFeature: Feature {
    public struct State: FeatureState {
        public var htmlString: String = ""
        public var javaScript: String = ""
        var requestType: String = ""
        let enableExternalScripts: Bool = false
        var nextUrl: String = ""
        //var cookies: ModuleCookies? = nil
        
        public init(htmlString: String, javaScript: String, requestType: String = "") {
            self.htmlString = htmlString
            self.javaScript = javaScript
            self.requestType = requestType
        }
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {
            case setNextUrl(newUrl: String)
            case setHtmlString(newString: String)
            case setJsString(newString: String)
            case setRequestType(type: String)
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setNextUrl(let newUrl):
                    state.nextUrl = newUrl
                    return .none
                case .setHtmlString(let newString):
                    state.htmlString = newString
                    return .none
                case .setJsString(let newString):
                    print("SETTING JS")
                    state.javaScript = newString
                    return .none
                case .setRequestType(let type):
                    state.requestType = type
                    return .none
                }
            }
        }
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<WebviewFeature>
        public let payload: String
        public let action: String
        public let completionHandler: ((String) -> Void)?
        
        public init(store: StoreOf<WebviewFeature>, payload: String? = "", action: String? = "logic", completionHandler: ((String) -> Void)? = nil) {
            self.store = store
            self.payload = payload ?? ""
            self.action = action ?? "logic"
            self.completionHandler = completionHandler
        }
        
        public nonisolated init(store: StoreOf<WebviewFeature>) {
            self.store = store
            self.payload = ""
            self.action = ""
            self.completionHandler = nil
        }
    }
    
    public init() {}
}

extension WebviewFeature.View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            WebView(viewStore: viewStore, payload: payload, completionHandler: completionHandler, action: action)
        }
    }
}
