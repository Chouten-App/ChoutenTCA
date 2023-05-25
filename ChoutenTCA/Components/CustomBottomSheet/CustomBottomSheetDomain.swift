//
//  CustomBottomSheetDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI
import ComposableArchitecture

struct CustomBottomSheetDomain: ReducerProtocol {
    struct State: Equatable {
        var fromRight: Bool = UIScreen.main.bounds.width > 600
        var fromLeft: Bool = false
        
        var offsetY: Double = 0.0
        let alignment = Alignment.bottom
    }
    
    enum Action: Equatable {
        case setOffset(newY: Double)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setOffset(let newY):
            state.offsetY = newY
            return .none
        }
    }
}
