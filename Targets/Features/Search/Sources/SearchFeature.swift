//
//  SearchFeature.swift
//
//
//  Created by Inumaki on 14.10.23.
//

import Architecture
import ComposableArchitecture
import Info
import OSLog
import SharedModels
import SwiftUI
import ViewComponents
import Webview

@Reducer
public struct SearchFeature: Feature {
  let logger = Logger(subsystem: "com.inumaki.Chouten", category: "Search")

  @ObservableState
  public struct State: FeatureState {
    public var webviewState: WebviewFeature.State
    public var info: InfoFeature.State

    public var query: String
    public var lastQuery: String = ""
    public var page = 1
    public var wasLastPage = false
    public var isFetching = false

    public var htmlString = ""
    public var jsString = ""

    public var searchResults: [SearchData] = []
    public var searchLoadable: Loadable<[SearchData]> = .pending

    public var state: LoadingStatus = .notStarted
    public var itemOpacity: Double = 0.8
    public var scrollPosition: CGPoint = .zero
    public var headerOpacity: Double = 0.0

    public var infoVisible = false
    public var searchFocused = false
    public var dragState = CGSize.zero

    public init() {
      self.query = ""
      self.webviewState = WebviewFeature.State(htmlString: "", javaScript: "")
      self.info = InfoFeature.State(url: "")
    }
  }

  @Dependency(\.moduleClient) var moduleClient

  public enum LoadingStatus: Sendable, Equatable {
    case notStarted
    case loading
    case success
    case error
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction, BindableAction {
      case search
      case resetWebview
      case setItemOpacity(value: Double)
      case backButtonPressed
      case setScrollPosition(_ value: CGPoint)
      case setHeaderOpacity(_ value: Double)
      case setLoadingStatus(_ status: LoadingStatus)
      case setSearchData(_ data: [SearchData])
      case appendSearchData(_ data: [SearchData])
      case parseResult(data: String)
      case setInfo(_ url: String)
      case setInfoVisible(_ value: Bool)
      case setDragState(_ value: CGSize)
      case removeQuery(at: Int)
      case setSearchFocused(_ val: Bool)
      case increasePageNumber
      case setLoadable(_ state: Loadable<[SearchData]>)

      case binding(BindingAction<State>)
    }

    @CasePathable
    @dynamicMemberLookup
    public enum DelegateAction: SendableAction {}

    @CasePathable
    @dynamicMemberLookup
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
    @Perception.Bindable public var store: StoreOf<SearchFeature>
    // @Environment(\.namespace) var animation
    let animation: Namespace.ID
    @FocusState public var searchbarFocused: Bool

    public var headerOpacity: Double = 0.0

    public init(store: StoreOf<SearchFeature>, animation: Namespace.ID) {
      self.store = store
      self.animation = animation
    }

    public init(store: StoreOf<SearchFeature>) {
      self.store = store
      self.animation = Namespace().wrappedValue
    }
  }

  public init() {}
}
