//
//  GlobalData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture
import Combine

enum CustomColorScheme {
    case light
    case dark
    case system
}

private enum GlobalDataKey: DependencyKey {
    static let liveValue: GlobalData = {
        var module: CurrentValueSubject<Module?, Never> = .init(nil)
        var availableModules: [Module] = []
        var downloadedOnly: CurrentValueSubject<Bool, Never> = .init(false)
        let incognito: CurrentValueSubject<Bool, Never> = .init(false)
        var searchResults: CurrentValueSubject<[SearchData], Never> = .init([])
        var infoData: CurrentValueSubject<InfoData?, Never> = .init(nil)
        var homeData: CurrentValueSubject<[HomeComponent], Never> = .init([])
        var servers: CurrentValueSubject<[ServerData], Never> = .init([])
        var videoData: CurrentValueSubject<VideoData?, Never> = .init(nil)
        var nextUrl: CurrentValueSubject<String?, Never> = .init(nil)
        var logs: CurrentValueSubject<[ConsoleData], Never> = .init([])
        var cookies: CurrentValueSubject<ModuleCookies?, Never> = .init(nil)
        let showOverlay: CurrentValueSubject<Bool, Never> = .init(false)
        let colorScheme: CurrentValueSubject<CustomColorScheme, Never> = .init(.dark)
        
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
            setInfoDataMediaList: { list in
                if infoData.value != nil {
                    infoData.value!.mediaList = list
                }
            },
            getInfoData: {
                return infoData.value
            },
            observeInfoData: {
                infoData.values.eraseToStream()
            },
            setNextUrl: { next in
                nextUrl.value = next
            },
            getNextUrl: {
                return nextUrl.value
            },
            observeNextUrl: {
                nextUrl.values.eraseToStream()
            },
            setHomeData: { data in
                homeData.value = data
            },
            appendHomeData: { data in
                homeData.value.append(contentsOf: data)
            },
            getHomeData: {
                return homeData.value
            },
            observeHomeData: {
                homeData.values.eraseToStream()
            },
            setServers: { list in
                servers.value = list
            },
            getServers: {
                return servers.value
            },
            observeServers: {
                servers.values.eraseToStream()
            },
            setVideoData: { data in
                videoData.value = data
            },
            getVideoData: {
                return videoData.value
            },
            observeVideoData: {
                videoData.values.eraseToStream()
            },
            setLogs: { data in
                logs.value = data
            },
            appendLogs: { data in
                logs.value.append(data)
            },
            getLogs: {
                return logs.value
            },
            observeLogs: {
                logs.values.eraseToStream()
            },
            setCookies: { data in
                cookies.value = data
            },
            getCookies: {
                return cookies.value
            },
            observeCookies: {
                cookies.values.eraseToStream()
            },
            setShowOverlay: { newValue in
                showOverlay.value = newValue
            },
            getShowOverlay: {
                return showOverlay.value
            },
            observeShowOverlay: {
                showOverlay.values.eraseToStream()
            },
            setColorScheme: { newValue in
                colorScheme.value = newValue
            },
            getColorScheme: {
                return colorScheme.value
            },
            observeColorScheme: {
                colorScheme.values.eraseToStream()
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
    
    var setInfoData: (_ results: InfoData?) -> Void
    var setInfoDataMediaList: (_ results: [MediaList]) -> Void
    var getInfoData: () -> InfoData?
    var observeInfoData: () -> AsyncStream<InfoData?>
    
    var setNextUrl: (_ results: String?) -> Void
    var getNextUrl: () -> String?
    var observeNextUrl: () -> AsyncStream<String?>
    
    var setHomeData: (_ results: [HomeComponent]) -> Void
    var appendHomeData: (_ results: [HomeComponent]) -> Void
    var getHomeData: () -> [HomeComponent]
    var observeHomeData: () -> AsyncStream<[HomeComponent]>
    
    var setServers: (_ results: [ServerData]) -> Void
    var getServers: () -> [ServerData]
    var observeServers: () -> AsyncStream<[ServerData]>
    
    var setVideoData: (_ results: VideoData?) -> Void
    var getVideoData: () -> VideoData?
    var observeVideoData: () -> AsyncStream<VideoData?>
    
    var setLogs: (_ results: [ConsoleData]) -> Void
    var appendLogs: (_ results: ConsoleData) -> Void
    var getLogs: () -> [ConsoleData]
    var observeLogs: () -> AsyncStream<[ConsoleData]>
    
    var setCookies: (_ results: ModuleCookies?) -> Void
    var getCookies: () -> ModuleCookies?
    var observeCookies: () -> AsyncStream<ModuleCookies?>
    
    var setShowOverlay: (_ newValue: Bool) -> Void
    var getShowOverlay: () -> Bool
    var observeShowOverlay: () -> AsyncStream<Bool>
    
    var setColorScheme: (_ newValue: CustomColorScheme) -> Void
    var getColorScheme: () -> CustomColorScheme
    var observeColorScheme: () -> AsyncStream<CustomColorScheme>
}
