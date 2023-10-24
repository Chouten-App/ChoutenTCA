//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture

extension PlayerFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setPiP(_):
                    return .none
                case .setSpeed(let value):
                    state.speed = value
                    return .none
                case .setServer(let value):
                    state.server = value
                    return .none
                case .setQuality(let value):
                    state.quality = value
                    return .none
                case .setShowMenu(let value):
                    state.showMenu = value
                    return .none
                }
            }
        }
    }
}
