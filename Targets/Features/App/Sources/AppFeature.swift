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

public struct AppFeature: Feature {
  @Dependency(\.dataClient) var dataClient
  @Dependency(\.moduleClient) var moduleClient

  public struct State: FeatureState {
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.versionString == rhs.versionString &&
        lhs.more == rhs.more &&
        lhs.discover == rhs.discover &&
        lhs.player == rhs.player &&
        lhs.sheet == rhs.sheet &&
        lhs.selected == rhs.selected &&
        lhs.showTabbar == rhs.showTabbar &&
        lhs.showPlayer == rhs.showPlayer &&
        lhs.fullscreen == rhs.fullscreen &&
        lhs.videoUrl == rhs.videoUrl &&
        lhs.videoIndex == rhs.videoIndex &&
        lhs.selectedModuleId == rhs.selectedModuleId &&
        lhs.mediaItems == rhs.mediaItems &&
        lhs.modules == rhs.modules
    }

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

    @AppStorage("selectedModuleId") public var selectedModuleId: String = ""

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

  public enum Action: FeatureAction {
    public enum ViewAction: SendableAction {
      case changeTab(_ tab: State.Tab)
      case toggleTabbar
      case onAppear
      case setVideoUrl(_ url: String?, index: Int?)
      case updateMediaItems(_ items: [Media])
    }

    public enum DelegateAction: SendableAction {}

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

    public nonisolated init(store: StoreOf<AppFeature>) {
      self.store = store
    }
  }

  public init() {}
}
