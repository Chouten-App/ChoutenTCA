//
//  ModuleSelectorDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture

struct ModuleSelectorDomain: ReducerProtocol {
    struct State: Equatable {
        var buttonHeight: Double = 52
        var importPressed: Bool = false
        var isModule: Bool = true
        
        var fileUrl: String = ""
        var filename: String = ""
    }
    
    enum Action: Equatable {
        case setFileUrl(newUrl: String)
        case setFilename(newName: String)
        case setIsModule(newValue: Bool)
        case setImportedPressed(newValue: Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setFileUrl(let newUrl):
            state.fileUrl = newUrl
            return .none
        case .setFilename(let newName):
            state.filename = newName
            return .none
        case .setIsModule(let newValue):
            state.isModule = newValue
            return .none
        case .setImportedPressed(let newValue):
            state.importPressed = newValue
            return .none
        }
    }
}
