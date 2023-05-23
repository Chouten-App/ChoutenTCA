//
//  FloatyDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture

struct FloatyDomain: ReducerProtocol {
    struct State: Equatable {
        var message: String = ""
        var error: Bool = false
        var action: FloatyAction? = nil
        var showFloaty: Bool = false
    }
    
    enum Action: Equatable {
        case setFloatyBool(newValue: Bool)
        case setFloatyData(message: String, error: Bool, action: FloatyAction?)
        case setFloatyMessage(message: String)
        case setFloatyError(error: Bool)
        case setFloatyAction(action: FloatyAction?)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setFloatyBool(let newValue):
                state.showFloaty = newValue
                return .none
            case .setFloatyData(let message, let error, let action):
                state.message = message
                state.error = error
                state.action = action
                return .none
            case .setFloatyMessage(let message):
                state.message = message
                return .none
            case .setFloatyError(let error):
                state.error = error
                return .none
            case .setFloatyAction(let action):
                state.action = action
                return .none
            }
        }
        ._printChanges()
    }
}
