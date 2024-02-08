//
//  AppFeature.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import DataClient
import Discover
import ModuleSheet
import More
import Player
import SharedModels
import SwiftUI

@Reducer
public struct AppFeature: Feature {
  @Dependency(\.dataClient) var dataClient
  @Dependency(\.moduleClient) var moduleClient

  @ObservableState
  public struct State: FeatureState {
    let versionString: String
    public var more: MoreFeature.State
    public var discover: DiscoverFeature.State
    public var player: PlayerFeature.State
    public var sheet: ModuleSheetFeature.State

    public var selected = Tab.home
    public var showTabbar = true
    public var showPlayer = false
    public var fullscreen = false
    public var videoUrl: String?
    public var videoIndex: Int?

    public var mediaItems: [Media] = []
    public var modules: [Module] = []

    public var selectedModuleId: String = ""

    public init(versionString: String = "x.x.x(x)") {
      self.versionString = versionString
      self.more = MoreFeature.State(
        versionString: versionString
      )
      self.discover = DiscoverFeature.State()
      self.player = PlayerFeature.State()
      self.sheet = ModuleSheetFeature.State()
    }

    public enum Tab: String, CaseIterable, Sendable {
      case home = "Home"
      case discover = "Discover"
      case repos = "Repos"
      case more = "More"

      var image: String {
        switch self {
        case .home:
          "house"
        case .discover:
          "safari"
        case .repos:
          "shippingbox"
        case .more:
          "ellipsis"
        }
      }

      var selected: String {
        switch self {
        case .home:
          "house.fill"
        case .discover:
          "safari.fill"
        case .repos:
          "shippingbox.fill"
        case .more:
          "ellipsis"
        }
      }
    }
  }

  @CasePathable
  @dynamicMemberLookup
  public enum Action: FeatureAction {
    @CasePathable
    @dynamicMemberLookup
    public enum ViewAction: SendableAction {
      case changeTab(_ tab: State.Tab)
      case toggleTabbar
      case onAppear
      case setVideoUrl(_ url: String?, index: Int?)
      case updateMediaItems(_ items: [Media])
    }

    @CasePathable
    @dynamicMemberLookup
    public enum DelegateAction: SendableAction {}

    @CasePathable
    @dynamicMemberLookup
    public enum InternalAction: SendableAction {
      case more(MoreFeature.Action)
      case discover(DiscoverFeature.Action)
      case player(PlayerFeature.Action)
      case sheet(ModuleSheetFeature.Action)
    }

    case view(ViewAction)
    case delegate(DelegateAction)
    case `internal`(InternalAction)
  }

  @MainActor
  public struct View: FeatureView {
    @Namespace var animation
    public let store: StoreOf<AppFeature>
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage("colorScheme") var colorScheme: Int?
    @SwiftUI.State var showContextMenu = false
    @SwiftUI.State var hoveredIndex = -1
    @GestureState var press = false

    @SwiftUI.State var showAlert = false
    @SwiftUI.State var changeMediaData: Media?

    public init(store: StoreOf<AppFeature>) {
      self.store = store
    }
  }

  public init() {}
}
