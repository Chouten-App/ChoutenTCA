//
//  GridCardDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation
import ComposableArchitecture

struct GridCardDomain: ReducerProtocol {
    struct State: Equatable {
        var data: SearchData
    }
    
    enum Action: Equatable {}
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        return .none
    }
}
