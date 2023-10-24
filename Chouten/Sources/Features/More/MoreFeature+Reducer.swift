//
//  File.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import ComposableArchitecture

extension MoreFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: /State.self, action: /Action.view) {
            BindingReducer()
        }

        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .binding:
                    return .none
                }
            }
        }
    }
}
