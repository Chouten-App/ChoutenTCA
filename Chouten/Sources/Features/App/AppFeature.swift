//
//  File.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import SwiftUI
import More
import Discover
import Player
import ModuleSheet
import DataClient

public struct AppFeature: Feature {
    @Dependency(\.dataClient) var dataClient
    
    public struct State: FeatureState {
        let versionString: String
        public var more: MoreFeature.State
        public var discover: DiscoverFeature.State
        public var player: PlayerFeature.State
        public var sheet: ModuleSheetFeature.State
        
        public var selected = Tab.home
        public var showTabbar: Bool = true
        public var showPlayer: Bool = false
        public var fullscreen: Bool = false
        public var videoUrl: String? = nil
        
        public init(versionString: String = "x.x.x") {
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
                    return "house"
                case .discover:
                    return "safari"
                case .repos:
                    return "shippingbox"
                case .more:
                    return "ellipsis"
                }
            }
            
            var selected: String {
                switch self {
                case .home:
                    return "house.fill"
                case .discover:
                    return "safari.fill"
                case .repos:
                    return "shippingbox.fill"
                case .more:
                    return "ellipsis"
                }
            }
        }
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {
            case changeTab(_ tab: State.Tab)
            case toggleTabbar
            case onAppear
            case setVideoUrl(_ url: String?)
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
        
        public nonisolated init(store: StoreOf<AppFeature>) {
            self.store = store
        }
    }
    
    public init() {}
}
