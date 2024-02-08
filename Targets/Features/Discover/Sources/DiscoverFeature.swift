//
//  DiscoverFeature.swift
//
//
//  Created by Inumaki on 12.10.23.
//

import Architecture
import ComposableArchitecture
import ModuleClient
import Search
import SwiftUI

@Reducer
public struct DiscoverFeature: Feature {
  @ObservableState
  public struct State: FeatureState {
    public var search: SearchFeature.State

    public var state: LoadingStatus = .notStarted
    public var searchVisible = false

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

  @Dependency(\.moduleClient) var moduleClient

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction, BindableAction {
      case onAppear
      case setState(newState: LoadingStatus)
      case setSearchVisible(newValue: Bool)
      case setCarouselIndex(value: Int)
      case setScrollPosition(_ value: CGPoint)
      case refresh

      case binding(BindingAction<State>)
    }

    @CasePathable
    @dynamicMemberLookup
    public enum DelegateAction: SendableAction {}

    @CasePathable
    @dynamicMemberLookup
    public enum InternalAction: SendableAction {
      case search(SearchFeature.Action)
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    @Perception.Bindable public var store: StoreOf<DiscoverFeature>
    @Namespace var animation

    public func refreshPercentage(scrollPosition: CGPoint) -> CGFloat {
      if scrollPosition.y > 170 { return 1.0 }

      return scrollPosition.y / CGFloat(170)
    }

    public init(store: StoreOf<DiscoverFeature>) {
      self.store = store
    }
  }

  public init() {}
}
