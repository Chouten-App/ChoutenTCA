//
//  DiscoverFeature.swift
//  Discover
//
//  Created by Inumaki on 19.04.24.
//

import ComposableArchitecture
import Combine
import SwiftUI

@Reducer
struct DiscoverFeature: Reducer {
    // @Dependency(\.relayClient) var relayClient

    @ObservableState
    struct State: FeatureState {
        var discoverSections: [DiscoverSection] = []

        init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        enum ViewAction: SendableAction {
            case onAppear
            case setDiscoverSections(_ data: [DiscoverSection])
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
                    return .none
                    /*
                    return .merge(
                        .run { send in
                            do {
                                let data = try await self.relayClient.discover()
                                await send(.view(.setDiscoverSections(data)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                     */
                case .setDiscoverSections(let data):
                    state.discoverSections = data
                    return .none
                }
            }
        }
    }
}
