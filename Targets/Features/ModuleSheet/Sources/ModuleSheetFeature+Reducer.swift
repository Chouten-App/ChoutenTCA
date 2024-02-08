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
      case .view(.onAppear):
        do {
          let modules = try moduleClient.getModules()

          state.availableModules = modules
        } catch {
          logger.error("\(error.localizedDescription)")
        }

        state.selectedModule = moduleClient.getCurrentModule()

        return .run { send in
          for await module in moduleClient.currentModuleStream() {
            await send(.internal(.setCurrentModule(module)))
          }
        }

      case let .view(.selectModule(module)):
        moduleClient.setCurrentModule(module: module)

      case let .internal(.setCurrentModule(module)):
        state.selectedModule = module
      }
      return .none
    }
  }
}
