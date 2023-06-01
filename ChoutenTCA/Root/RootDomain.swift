//
//  RootDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture

struct RootDomain: ReducerProtocol {
    struct State: Equatable {
        var navigate: Bool = false
    }
    
    enum Action: Equatable {
        case setNavigate(newValue: Bool)
        case onAppear
        case setAvailableModules(TaskResult<[Module]>)
        case setSelectedModuleId(id: String)
    }
    
    @Dependency(\.globalData)
    var globalData
    
    @Dependency(\.moduleManager)
    var moduleManager
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setNavigate(let newValue):
            state.navigate = newValue
            return .none
        case .onAppear:
            return .task {
                await .setAvailableModules(
                    TaskResult {
                        try moduleManager.getModules()
                    }
                )
            }
        case .setAvailableModules(.success(let modules)):
            globalData.setAvailableModules(modules)
            return .none
        case .setAvailableModules(.failure(let error)):
            print(error)
            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
            NotificationCenter.default
                .post(name:           NSNotification.Name("floaty"),
                      object: nil, userInfo: data)
            return .none
        case .setSelectedModuleId(let id):
            do {
                let temp = try moduleManager.getModules().filter { $0.id == id }
                print(temp)
                if temp.count > 0 {
                    globalData.setModule(temp[0])
                    let module = globalData.getModule()
                    
                    if module != nil {
                        moduleManager.setSelectedModuleName(module!)
                    }
                }
            } catch let error {
                print(error)
            }
            return .none
        }
    }
}
