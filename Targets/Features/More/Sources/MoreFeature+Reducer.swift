//
//  MoreFeature+Reducer.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Appearance
import Architecture
import ComposableArchitecture

extension MoreFeature {
  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
    Scope(\.view) {
      BindingReducer()
    }

    Scope(state: \.appearance, action: \.internal.appearance) {
      AppearanceFeature()
    }

    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case let .setPageState(to):
          state.pageState = to
          print(to)
          return .none
        case .binding:
          return .none
        }
      case let .internal(internalAction):
        switch internalAction {
        case .appearance:
          return .none
        }
      }
    }
  }
}
