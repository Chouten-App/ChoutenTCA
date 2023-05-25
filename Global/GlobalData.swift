//
//  GlobalData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture
import Combine

private enum GlobalDataKey: DependencyKey {
    static let liveValue: GlobalData = {
        var module: Module? = nil
        var availableModules: [Module] = []
        var downloadedOnly: CurrentValueSubject<Bool, Never> = .init(false)
        let incognito: CurrentValueSubject<Bool, Never> = .init(false)
        return GlobalData(
            setAvailableModules: { newList in
                availableModules = newList
            },
            appendAvailableModules: { data in
                availableModules.append(data)
            },
            setIncognito: { newValue in
                incognito.value = newValue
            },
            getIncognito: {
                return incognito.value
            },
            observeIncognito: {
                incognito.values.eraseToStream()
            },
            setDownloadedOnly: { newValue in
                downloadedOnly.value = newValue
            },
            getDownloadedOnly: {
                return downloadedOnly.value
            },
            observeDownloadedOnly: {
                downloadedOnly.values.eraseToStream()
            }
        )
    }()
}
extension DependencyValues {
    var globalData: GlobalData {
        get { self[GlobalDataKey.self] }
        set { self[GlobalDataKey.self] = newValue }
    }
}

struct GlobalData {
    var setAvailableModules: (_ newList: [Module]) -> Void
    var appendAvailableModules: (_ addData: Module) -> Void
    
    var setIncognito: (_ newValue: Bool) -> Void
    var getIncognito: () -> Bool
    var observeIncognito: () -> AsyncStream<Bool>
    
    var setDownloadedOnly: (_ newValue: Bool) -> Void
    var getDownloadedOnly: () -> Bool
    var observeDownloadedOnly: () -> AsyncStream<Bool>
}
