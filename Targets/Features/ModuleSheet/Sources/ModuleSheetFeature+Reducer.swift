//
//  ModuleSheetFeature+Reducer.swift
//
//
//  Created by Inumaki on 19.10.23.
//

import Architecture
import ComposableArchitecture

extension ModuleSheetFeature {
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case let .setContentHeight(newHeight):
          state.contentHeight = newHeight
          return .none
        case let .setOffset(newY):
          state.offset = newY
          return .none
        case let .setOffsetAndTemp(newY):
          state.tempOffset = state.offset
          state.offset = newY
          return .none
        case let .updateOffset(newY):
          state.offset += newY
          return .none
        case let .setTempOffset(newY):
          state.tempOffset = newY
          return .none
        case let .updateTempOffset(newY):
          state.tempOffset += newY
          return .none
        case let .setAnimate(value):
          state.animate = value
          return .none
        case let .setModule(module):
          moduleClient.setCurrentModule(module)
          state.selectedModuleId = module.id
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
