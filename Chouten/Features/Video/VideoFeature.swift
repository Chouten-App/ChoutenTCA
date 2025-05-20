//
//  SearchFeature.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Core
import Combine
import ComposableArchitecture
import SwiftUI

@Reducer
struct VideoFeature: Reducer {
    @Dependency(\.relayClient) var relayClient
    @Dependency(\.databaseClient) var databaseClient

    @ObservableState
    struct State: FeatureState {
        var videoData: MediaStream?
        var serverLists: [SourceList]?
        var status: VideoStatus = .idle
        init() { }
    }

    enum VideoStatus: Equatable, Sendable {
        case idle
        case loading
        case success
        case error
    }

    @CasePathable
    @dynamicMemberLookup
    enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        enum ViewAction: SendableAction {
            case onAppear(_ url: String)
            case getServers(_ url: String)
            case setServers(_ data: [SourceList])
            case getSources(_ url: String)
            case setSources(_ data: MediaStream)
            case updateContinueWatching(_ infoData: InfoData, _ mediaData: MediaItem, _ progress: Double, _ duration: Double)
            case removeFromContinueWatching(_ moduleId: String, _ url: String)
        }

        @CasePathable
        @dynamicMemberLookup
        enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    init() { }

    @ReducerBuilder<State, Action> var body: some ReducerOf<Self> {
        Reduce { state, action in
        switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear(let url):
                    state.status = .loading
                    return .send(.view(.getServers(url)))
                case .getServers(let url):
                    return .merge(
                        .run { send in
                            do {
                                let servers = try await relayClient.sources(url)
                                await send(.view(.setServers(servers)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                case .setServers(let data):
                    state.serverLists = data
                    if let firstServerList = data.first,
                        let firstServer = firstServerList.list.first {
                        let serverUrl = firstServer.url
                        return .send(.view(.getSources(serverUrl)))
                    }
                    return .none
                case .getSources(let url):
                    return .merge(
                        .run { send in
                            do {
                                let sources = try await relayClient.streams(url)
                                await send(.view(.setSources(sources)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                case .setSources(let data):
                    state.videoData = data
                    state.status = .success
                    return .none
                case .updateContinueWatching(let infoData, let mediaData, let progress, let duration):
                    if let moduleId = UserDefaults.standard.string(forKey: "selectedModuleId") {
                        return .merge(
                            .run { send in
                                await self.databaseClient.addToContinueWatching(moduleId, CollectionItem(infoData: infoData, url: infoData.url, mediaItem: mediaData, flag: .none), progress, duration)
                            }
                        )
                    }
                    return .none
                case .removeFromContinueWatching(let moduleId, let url):
                    return .merge(
                        .run { send in
                            await self.databaseClient.removeFromContinueWatching(moduleId, url)
                        }
                    )
                }
            }
        }
    }
}
