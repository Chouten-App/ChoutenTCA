//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import ComposableArchitecture
import More
import Discover
import SwiftUI
import Player
import ModuleSheet

extension AppFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: \.more, action: /Action.InternalAction.more) {
            MoreFeature()
        }
        
        Scope(state: \.discover, action: /Action.InternalAction.discover) {
            DiscoverFeature()
        }
        
        Scope(state: \.player, action: /Action.InternalAction.player) {
            PlayerFeature()
        }
        
        Scope(state: \.sheet, action: /Action.InternalAction.sheet) {
            ModuleSheetFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    if let jsURL = Bundle.main.url(forResource: "commonCode", withExtension: "js"),
                       let commonCode = try? String(contentsOf: jsURL) {
                        AppConstants.commonCode = commonCode
                    } else {
                        print("Couldnt find commonCode.js")
                    }
                    return .merge(
                        .run { send in
                            let videoUrlStream = dataClient.observeVideoUrl()
                            for await value in videoUrlStream {
                                await send(.view(.setVideoUrl(value)))
                            }
                        }
                    )
                case .setVideoUrl(let url):
                    state.videoUrl = url
                    if let url, !url.isEmpty {
                        state.player = PlayerFeature.State(url: url)
                        state.showPlayer = true
                    }
                    return .none
                case .changeTab(let tab):
                    state.selected = tab
                    return .none
                case .toggleTabbar:
                    state.showTabbar.toggle()
                    return .none
                }
            case let .internal(internalAction):
                switch internalAction {
                case .more:
                    return .none
                case .discover(.view(.setSearchVisible(let newValue))):
                    if newValue {
                        withAnimation {
                            state.showTabbar = false
                        }
                    } else {
                        withAnimation {
                            state.showTabbar = true
                        }
                    }
                    return .none
                case .discover:
                    return .none
                case .player(.view(.setPiP(let value))):
                    state.showPlayer = !value
                    return .none
                case .player(.view(.setFullscreen(let value))):
                    state.fullscreen = value
                    return .none
                case .player:
                    return .none
                case .sheet:
                    return .none
                }
            }
        }
    }
}
