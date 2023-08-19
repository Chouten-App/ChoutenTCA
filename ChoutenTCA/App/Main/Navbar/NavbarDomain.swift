//
//  NavbarDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import SwiftUI
import ComposableArchitecture

struct NavbarDomain: ReducerProtocol {
    struct State: Equatable {
        var tab: Int = 0
        var screenWidth: Double = UIScreen.main.bounds.width
        var screenHeight: Double = UIScreen.main.bounds.height
    }
    
    enum Action: Equatable {
        case setTab(newTab: Int)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setTab(let newTab):
            state.tab = newTab
            return .none
        }
    }
}
