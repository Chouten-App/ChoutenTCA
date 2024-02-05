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

public struct MoreFeature: Feature {
  public struct State: FeatureState {
    public static func == (lhs: MoreFeature.State, rhs: MoreFeature.State) -> Bool {
      lhs.isDownloadedOnly == rhs.isDownloadedOnly &&
        lhs.isIncognito == rhs.isIncognito &&
        lhs.pageState == rhs.pageState &&
        lhs.versionString == rhs.versionString
    }

    @AppStorage("downloadedOnly") public var isDownloadedOnly = false
    @AppStorage("incognito") public var isIncognito = false

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

  public enum Action: FeatureAction {
    public enum ViewAction: SendableAction, BindableAction {
      case setPageState(to: PageState)
      case binding(BindingAction<State>)
    }

    public enum DelegateAction: SendableAction {}
    public enum InternalAction: SendableAction {
      case appearance(AppearanceFeature.Action)
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    public let store: StoreOf<MoreFeature>

    public nonisolated init(store: StoreOf<MoreFeature>) {
      self.store = store
    }
  }

  public init() {}
}
