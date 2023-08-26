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
        
        var contentHeight: Double = 0.0
        
        var offsetY: Double = 0.0
        var tempOffsetY: Double = 0.0
        let alignment = Alignment.bottom
    }
    
    enum Action: Equatable {
        case setContentHeight(newHeight: Double)
        
        case setOffset(newY: Double)
        case setOffsetAndTemp(newY: Double)
        case updateOffset(newY: Double)
        case setTempOffset(newY: Double)
        case updateTempOffset(newY: Double)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setContentHeight(let newHeight):
            state.contentHeight = newHeight
            return .none
        case .setOffset(let newY):
            state.offsetY = newY
            return .none
        case .setOffsetAndTemp(let newY):
            state.tempOffsetY = state.offsetY
            state.offsetY = newY
            return .none
        case .updateOffset(let newY):
            state.offsetY += newY
            return .none
        case .setTempOffset(let newY):
            state.tempOffsetY = newY
            return .none
        case .updateTempOffset(let newY):
            state.tempOffsetY += newY
            return .none
        }
    }
}
