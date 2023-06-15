//
//  LogsDomain.swift
//  ChoutenTCA
//
//  Created by Inumaki on 07.06.23.
//

import Foundation
import ComposableArchitecture

struct LogsDomain: ReducerProtocol {
    struct State: Equatable {
        var logs: [ConsoleData] = []
        var isIncognito: Bool = false
        var isDownloadedOnly: Bool = false
    }
    
    enum Action: Equatable {
        case setLogs(newList: [ConsoleData])
        case appendLog(newItem: ConsoleData)
        case onAppear
        case setIncognito(newValue: Bool)
        case setDownloadedOnly(newValue: Bool)
    }
    
    @Dependency(\.globalData)
    var globalData
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .setLogs(let newList):
            state.logs = newList
            globalData.setLogs(newList)
            return .none
        case .appendLog(let newItem):
            state.logs.append(newItem)
            globalData.appendLogs(newItem)
            return .none
        case .setIncognito(let newValue):
            state.isIncognito = newValue
            return .none
        case .setDownloadedOnly(let newValue):
            state.isDownloadedOnly = newValue
            return .none
        case .onAppear:
            state.isIncognito = globalData.getIncognito()
            state.isDownloadedOnly = globalData.getIncognito()
            state.logs = globalData.getLogs()
            
            return .merge(
                .run { send in
                    let incognitoStream = globalData.observeIncognito()
                    for await value in incognitoStream {
                        await send(.setIncognito(newValue: value), animation: .easeOut(duration: 0.2))
                    }
                },
                .run { send in
                    let downloadedOnly = globalData.observeDownloadedOnly()
                    for await value in downloadedOnly {
                        await send(.setDownloadedOnly(newValue: value), animation: .easeOut(duration: 0.2))
                    }
                },
                .run { send in
                    let logs = globalData.observeLogs()
                    for await value in logs {
                        await send(.setLogs(newList: value), animation: .easeOut(duration: 0.2))
                    }
                }
            )
        }
    }
}
