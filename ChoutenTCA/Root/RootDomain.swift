//
//  RootDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture

struct RootDomain: ReducerProtocol {
    struct State: Equatable {
        var navigate: Bool = false
    }
    
    enum Action: Equatable {
        case setNavigate(newValue: Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setNavigate(let newValue):
            state.navigate = newValue
            return .none
        }
    }
}
