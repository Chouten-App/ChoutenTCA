//
//  DiscoverFeature+Reducer.swift
//
//
//  Created by Inumaki on 12.10.23.
//

import Architecture
import ComposableArchitecture
import Search
import SwiftUI

extension DiscoverFeature: Reducer {
  public var body: some ReducerOf<Self> {
    Scope(state: /State.self, action: /Action.view) {
      BindingReducer()
    }

    Scope(state: \.search, action: /Action.InternalAction.search) {
      SearchFeature()
    }

    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case let .setScrollPosition(value):
          state.scrollPosition = value
          return .none
        case let .setCarouselIndex(value):
          state.carouselIndex = value
          return .none
        case let .setSearchVisible(newValue):
          state.searchVisible = newValue
          return .none
        case let .setState(newState):
          state.state = newState
          return .none
        case .binding:
          return .none
        case .refresh:
          state.state = .notStarted
          return .none
        case .onAppear:
          return .run {}
        }
      case let .internal(internalAction):
        switch internalAction {
        case .search(.view(.backButtonPressed)):
          return .send(.view(.setSearchVisible(newValue: false)))
        case .search:
          return .none
        }
      }
    }
  }
}
