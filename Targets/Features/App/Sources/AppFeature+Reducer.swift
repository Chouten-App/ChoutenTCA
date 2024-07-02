//
//  AppFeature+Reducer.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import Combine
import ComposableArchitecture
import RepoClient
import SharedModels
import SwiftUI

extension AppFeature {
  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case .onAppear:
            return .none
        case let .changeTab(tab):
          state.selected = tab
          return .none
        case .toggleTabbar:
          return .none
        case .install(let url):
            guard let checkedUrl = URL(string: url) else {
                return .send(.view(.onAppear))
            }

            return .merge(
                .run { _ in
                    do {
                        try await repoClient.installRepo(checkedUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            )
        }
      }
    }
  }
}
