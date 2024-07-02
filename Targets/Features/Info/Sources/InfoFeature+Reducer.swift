//
//  InfoFeature+Reducer.swift
//  Info
//
//  Created by Inumaki on 25.04.24.
//

import Architecture
import Combine
import ComposableArchitecture
import SharedModels
import SwiftUI

extension InfoFeature {
  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case .onAppear(let url):
            return .merge(
                .run { send in
                    do {
                        let data = try await self.relayClient.info(url)
                        print(data)
                        await send(.view(.setInfoData(data)))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            )
        case .fetchMedia(let url):
            return .merge(
                .run { send in
                    do {
                        let data = try await self.relayClient.media(url)
                        print(data)
                        await send(.view(.setMediaList(data)))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            )
        case .setInfoData(let data):
            state.infoData = data

            if let url = data.seasons.first(where: { $0.selected == true })?.url {
                return .send(.view(.fetchMedia(url)))
            } else if let url = data.seasons.first?.url {
                return .send(.view(.fetchMedia(url)))
            }

            state.doneLoading = true

            return .none
        case .setMediaList(let data):
            state.infoData?.mediaList = data
            state.doneLoading = true
            return .none
        }
      }
    }
  }
}
