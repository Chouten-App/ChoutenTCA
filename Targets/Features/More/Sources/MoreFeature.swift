//
//  MoreFeature.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Appearance
import Architecture
import ComposableArchitecture
import SwiftUI

@Reducer
public struct MoreFeature: Feature {
  @ObservableState
  public struct State: FeatureState {
    public var isDownloadedOnly = false
    public var isIncognito = false
    public var pageState: PageState = .developer

    let versionString: String
    public var appearance: AppearanceFeature.State

    public init(versionString: String) {
      self.versionString = versionString
      self.appearance = AppearanceFeature.State()
    }
  }

  public enum PageState: String, Sendable {
    case more
    case appearance
    case developer
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction, BindableAction {
      case setPageState(to: PageState)
      case binding(BindingAction<State>)
    }

    @CasePathable
    @dynamicMemberLookup
    public enum DelegateAction: SendableAction {}

    @CasePathable
    @dynamicMemberLookup
    public enum InternalAction: SendableAction {
      case appearance(AppearanceFeature.Action)
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    @Perception.Bindable public var store: StoreOf<MoreFeature>

    public init(store: StoreOf<MoreFeature>) {
      self.store = store
    }
  }

  public init() {}
}
