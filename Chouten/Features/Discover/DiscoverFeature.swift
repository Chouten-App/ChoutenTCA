//
//  DiscoverFeature.swift
//  Discover
//
//  Created by Inumaki on 19.04.24.
//

import Core
import ComposableArchitecture
import Combine
import SwiftUI

@Reducer
struct DiscoverFeature: Reducer {
    @Dependency(\.relayClient) var relayClient
    @Dependency(\.databaseClient) var databaseClient

    @ObservableState
    struct State: FeatureState {
        var discoverSections: [DiscoverSection] = []
        var continueWatchingData: [DiscoverData] = []
        var isRefreshing: Bool = false

        init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        enum ViewAction: SendableAction {
            case onAppear
            case refresh
            case setDiscoverSections(_ data: [DiscoverSection])
            case setContinueWatchingData(_ data: [DiscoverData])
            case setIsRefreshing(_ isRefreshing: Bool)
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
    
    @ReducerBuilder<State, Action>  var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    state.discoverSections = []
                    state.continueWatchingData = []
                    return .merge(
                        .run { send in
                            do {
                                // Fetch discover data
                                let data = try await self.relayClient.discover()
                                await send(.view(.setDiscoverSections(data)))
                                
                                // Fetch continue watching data for current module
                                if let moduleId = UserDefaults.standard.string(forKey: "selectedModuleId"), !moduleId.isEmpty {
                                    let continueWatchingSection = await self.databaseClient.fetchContinueWatching()
                                    // Filter continue watching data for current module only
                                    let filteredData = continueWatchingSection.list.compactMap { homeData -> DiscoverData? in
                                        guard homeData.moduleId == moduleId else { return nil }
                                        
                                        return DiscoverData(
                                            url: homeData.url,
                                            titles: Titles(
                                                primary: homeData.titles.secondary ?? "Episode", 
                                                secondary: homeData.titles.primary
                                            ),
                                            description: homeData.description,
                                            poster: homeData.poster,
                                            label: homeData.label,
                                            indicator: homeData.indicator,
                                            isWidescreen: false,
                                            current: nil,
                                            total: nil
                                        )
                                    }
                                    await send(.view(.setContinueWatchingData(filteredData)))
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )

                case .refresh:
                    state.isRefreshing = true
                    return .merge(
                        .send(.view(.setIsRefreshing(true))),
                        .run { send in
                            do {
                                // Fetch discover data
                                let data = try await self.relayClient.discover()
                                await send(.view(.setDiscoverSections(data)))
                                
                                // Fetch continue watching data for current module
                                if let moduleId = UserDefaults.standard.string(forKey: "selectedModuleId"), !moduleId.isEmpty {
                                    let continueWatchingSection = await self.databaseClient.fetchContinueWatching()
                                    // Filter continue watching data for current module only
                                    let filteredData = continueWatchingSection.list.compactMap { homeData -> DiscoverData? in
                                        guard homeData.moduleId == moduleId else { return nil }
                                        
                                        return DiscoverData(
                                            url: homeData.url,
                                            titles: Titles(
                                                primary: homeData.titles.secondary ?? "Episode", 
                                                secondary: homeData.titles.primary
                                            ),
                                            description: homeData.description,
                                            poster: homeData.poster,
                                            label: homeData.label,
                                            indicator: homeData.indicator,
                                            isWidescreen: false,
                                            current: nil,
                                            total: nil
                                        )
                                    }
                                    await send(.view(.setContinueWatchingData(filteredData)))
                                }
                                
                                // End refreshing
                                await send(.view(.setIsRefreshing(false)))
                            } catch {
                                print(error.localizedDescription)
                                await send(.view(.setIsRefreshing(false)))
                            }
                        }
                    )

                case .setDiscoverSections(let data):
                    state.discoverSections = data
                    return .none
                    
                case .setContinueWatchingData(let data):
                    state.continueWatchingData = data
                    return .none
                    
                case .setIsRefreshing(let isRefreshing):
                    state.isRefreshing = isRefreshing
                    return .none
                }
            }
        }
    }
}
