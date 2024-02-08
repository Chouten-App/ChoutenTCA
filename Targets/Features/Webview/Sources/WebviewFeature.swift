//
//  WebviewFeature.swift
//
//
//  Created by Inumaki on 20.10.23.
//

import Architecture
import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - WebviewFeature

@Reducer
public struct WebviewFeature: Feature {
  @ObservableState
  public struct State: FeatureState {
    public var htmlString: String = ""
    public var javaScript: String = ""
    var requestType: String = ""
    let enableExternalScripts = false
    var nextUrl: String = ""
    // var cookies: ModuleCookies? = nil

    public init(htmlString: String, javaScript: String, requestType: String = "") {
      self.htmlString = htmlString
      self.javaScript = javaScript
      self.requestType = requestType
    }
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction {
      case setNextUrl(newUrl: String)
      case setHtmlString(newString: String)
      case setJsString(newString: String)
      case setRequestType(type: String)
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

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case let .setNextUrl(newUrl):
          state.nextUrl = newUrl
          return .none
        case let .setHtmlString(newString):
          state.htmlString = newString
          return .none
        case let .setJsString(newString):
          print("SETTING JS")
          state.javaScript = newString
          return .none
        case let .setRequestType(type):
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

    public init(store: StoreOf<WebviewFeature>) {
      self.store = store
      self.payload = ""
      self.action = ""
      self.completionHandler = nil
    }

    @MainActor public var body: some SwiftUI.View {
      WithPerceptionTracking {
        WebView(store: store, payload: payload, completionHandler: completionHandler, action: action)
      }
    }
  }

  public init() {}
}
