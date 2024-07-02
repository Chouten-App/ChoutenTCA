//
//  DiscoverFeature+Reducer.swift
//  Discover
//
//  Created by Inumaki on 19.04.24.
//

import Architecture
import Combine
import ComposableArchitecture
import SharedModels
import SwiftUI

extension DiscoverFeature {
  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case .onAppear:
            state.discoverSections = []
            return .merge(
                .run { send in
                    do {
                        let data = try await self.relayClient.discover()
                        print(data)
                        await send(.view(.setDiscoverSections(data)))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            )
        case .setDiscoverSections(let data):
            state.discoverSections = data
            return .none
        }
      }
    }
  }
}
