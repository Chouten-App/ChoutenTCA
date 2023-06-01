//
//  ModuleButtonDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation
import ComposableArchitecture

struct ModuleButtonDomain: ReducerProtocol {
    struct State: Equatable {
        var buttonText: String = "No Module"
    }
    
    enum Action: Equatable {
        case setButtonText(newText: String)
        case onAppear
    }
    
    @Dependency(\.globalData)
    var globalData
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setButtonText(let newText):
            state.buttonText = newText
            return .none
        case .onAppear:
            state.buttonText = globalData.getModule()?.name ?? "No Module"
            return .run { send in
                let moduleStream = globalData.observeModule()
                for await value in moduleStream {
                    await send(.setButtonText(newText: value?.name ?? "No Module"))
                }
            }
        }
    }
}
