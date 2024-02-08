//
//  AppearanceFeature.swift
//
//
//  Created by Inumaki on 04.11.23.
//

import Architecture
import ComposableArchitecture
import SharedModels
import SwiftUI

@Reducer
public struct AppearanceFeature: Feature {
  @ObservableState
  public struct State: FeatureState {
    // 0: Light, 1: Dark, 2: System
    public var colorScheme: Int = 2
    public var ambientMode = true
    public var dynamicInfo = true

    public init() {}
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction, BindableAction {
      case setColorScheme(to: ChoutenColorScheme)
      case binding(BindingAction<State>)
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

  @MainActor
  public struct View: FeatureView {
    @Perception.Bindable public var store: StoreOf<AppearanceFeature>

    public init(store: StoreOf<AppearanceFeature>) {
      self.store = store
    }
  }

  public init() {}
}
