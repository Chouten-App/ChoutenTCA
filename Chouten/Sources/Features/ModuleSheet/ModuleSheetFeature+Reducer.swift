//
//  File.swift
//  
//
//  Created by Inumaki on 19.10.23.
//

import Architecture
import ComposableArchitecture

extension ModuleSheetFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .setContentHeight(let newHeight):
                    state.contentHeight = newHeight
                    return .none
                case .setOffset(let newY):
                    state.offset = newY
                    return .none
                case .setOffsetAndTemp(let newY):
                    state.tempOffset = state.offset
                    state.offset = newY
                    return .none
                case .updateOffset(let newY):
                    state.offset += newY
                    return .none
                case .setTempOffset(let newY):
                    state.tempOffset = newY
                    return .none
                case .updateTempOffset(let newY):
                    state.tempOffset += newY
                    return .none
                case .setAnimate(let value):
                    state.animate = value
                    return .none
                case .onAppear:
                    do {
                        let modules = try moduleClient.getModules()
                        
                        state.availableModules = modules
                    } catch {
                        logger.error("\(error.localizedDescription)")
                    }
                    return .none
                }
            }
        }
    }
}
