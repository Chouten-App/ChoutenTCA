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
        var module: CurrentValueSubject<Module?, Never> = .init(nil)
        var availableModules: [Module] = []
        var downloadedOnly: CurrentValueSubject<Bool, Never> = .init(false)
        let incognito: CurrentValueSubject<Bool, Never> = .init(false)
        var searchResults: CurrentValueSubject<[SearchData], Never> = .init([])
        var infoData: CurrentValueSubject<InfoData?, Never> = .init(nil)
        
        return GlobalData(
            setModule: { newModule in
                module.value = newModule
            },
            getModule: {
                return module.value
            },
            observeModule: {
                module.values.eraseToStream()
            },
            setAvailableModules: { newList in
                availableModules = newList
            },
            getAvailableModules: {
                return availableModules
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
            },
            setSearchResults: { results in
                searchResults.value = results
            },
            getSearchResults: {
                return searchResults.value
            },
            observeSearchResults: {
                searchResults.values.eraseToStream()
            },
            setInfoData: { info in
                infoData.value = info
            },
            getInfoData: {
                return infoData.value
            },
            observeInfoData: {
                infoData.values.eraseToStream()
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
    var setModule: (_ module: Module) -> Void
    var getModule: () -> Module?
    var observeModule: () -> AsyncStream<Module?>
    
    var setAvailableModules: (_ newList: [Module]) -> Void
    var getAvailableModules: () -> [Module]
    var appendAvailableModules: (_ addData: Module) -> Void
    
    var setIncognito: (_ newValue: Bool) -> Void
    var getIncognito: () -> Bool
    var observeIncognito: () -> AsyncStream<Bool>
    
    var setDownloadedOnly: (_ newValue: Bool) -> Void
    var getDownloadedOnly: () -> Bool
    var observeDownloadedOnly: () -> AsyncStream<Bool>
    
    var setSearchResults: (_ results: [SearchData]) -> Void
    var getSearchResults: () -> [SearchData]
    var observeSearchResults: () -> AsyncStream<[SearchData]>
    
    var setInfoData: (_ results: InfoData) -> Void
    var getInfoData: () -> InfoData?
    var observeInfoData: () -> AsyncStream<InfoData?>
}
