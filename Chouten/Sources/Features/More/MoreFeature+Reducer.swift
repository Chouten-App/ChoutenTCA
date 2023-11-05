//
//  File.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import ComposableArchitecture
import Appearance

extension MoreFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: /State.self, action: /Action.view) {
            BindingReducer()
        }
        
        Scope(state: \.appearance, action: /Action.InternalAction.appearance) {
            AppearanceFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setPageState(let to):
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
