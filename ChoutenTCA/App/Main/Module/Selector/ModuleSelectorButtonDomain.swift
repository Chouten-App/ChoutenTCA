//
//  ModuleSelectorButtonDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import ComposableArchitecture
import Foundation
import SwiftUI

struct ModuleSelectorButtonDomain: ReducerProtocol {
    struct State: Equatable {
        var module: Module = .init(
            id: "",
            type: "",
            subtypes: [],
            name: "Zoro.to",
            version: "0.0.1",
            formatVersion: 1,
            updateUrl: "",
            general: GeneralMetadata(
                author: "Inumaki",
                description: "A Module to get data from Zoro.to",
                lang: [],
                baseURL: "",
                bgColor: "#ffcb3d",
                fgColor: "#000000"
            )
        )
        var isSelected: Bool = false
        
        let cornerRadius: CGFloat = 12
        var offset: CGFloat = 0
        var isSwiped: Bool = false
        
        var shouldAutoUpdate = false
    }
    
    enum Action: Equatable {
        case loadModule
        case deleteModule
        case deleteResult(TaskResult<Bool>)
        case setShouldAutoUpdate(newBool: Bool)
        case onChanged(value: DragGesture.Value)
        case onEnded(value: DragGesture.Value)
    }
    
    @Dependency(\.moduleManager)
    var moduleManager
    
    @Dependency(\.globalData)
    var globalData
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadModule:
            globalData.setModule(state.module)
            moduleManager.setSelectedModuleName(state.module)
            return .none
        case .deleteModule:
            let module = state.module
            return .task {
                await .deleteResult(
                    TaskResult {
                        try moduleManager.deleteModule(module)
                    }
                )
            }
        case .deleteResult(.success):
            return .none
        case .deleteResult(.failure(let error)):
            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
            NotificationCenter.default
                .post(name: NSNotification.Name("floaty"),
                      object: nil, userInfo: data)
            return .none
        case .setShouldAutoUpdate(let newBool):
            state.shouldAutoUpdate = newBool
            return .none
        case .onChanged(let value):
            if value.translation.width < 0 {
                if state.isSwiped {
                    state.offset = value.translation.width - 90
                } else {
                    state.offset = value.translation.width
                }
            }
            return .none
        case .onEnded(let value):
            if value.translation.width < 0 {
                if -value.translation.width > UIScreen.main.bounds.width / 2 {
                    state.offset = -1000
                    return .send(.deleteModule)
                } else if -state.offset > 50 {
                    state.isSwiped = true
                    state.offset = -90
                } else {
                    state.isSwiped = false
                    state.offset = 0
                }
            } else {
                state.isSwiped = false
                state.offset = 0
            }
            return .none
        }
    }
}
