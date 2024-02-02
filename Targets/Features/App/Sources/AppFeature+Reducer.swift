//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import ComposableArchitecture
import More
import Discover
import SwiftUI
import Player
import ModuleSheet
import GRDB
import SharedModels

extension AppFeature: Reducer {
    public var body: some ReducerOf<Self> {
        Scope(state: \.more, action: /Action.InternalAction.more) {
            MoreFeature()
        }
        
        Scope(state: \.discover, action: /Action.InternalAction.discover) {
            DiscoverFeature()
        }
        
        Scope(state: \.player, action: /Action.InternalAction.player) {
            PlayerFeature()
        }
        
        Scope(state: \.sheet, action: /Action.InternalAction.sheet) {
            ModuleSheetFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    do {
                        let modules = try moduleClient.getModules()
                        state.modules = modules
                        let currentModule = modules.first { m in
                            m.id == state.selectedModuleId
                        }
                        
                        if let currentModule {
                            moduleClient.setCurrentModule(currentModule)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    if let jsURL = Bundle.main.url(forResource: "commonCode", withExtension: "js"),
                       let commonCode = try? String(contentsOf: jsURL) {
                        AppConstants.commonCode = commonCode
                    } else {
                        print("Couldnt find commonCode.js")
                    }
                    
                    // Database
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        var isDirectory: ObjCBool = false
                        if !FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("Databases").path, isDirectory: &isDirectory) {
                            do {
                                try FileManager.default.createDirectory(at: documentsDirectory.appendingPathComponent("Databases"), withIntermediateDirectories: false, attributes: nil)
                                print("Created Database Directory")
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                        
                        do {
                            let dbQueue = try DatabaseQueue(path: documentsDirectory.appendingPathComponent("Databases").appendingPathComponent("chouten.sqlite").absoluteString)
                            
                            try dbQueue.write { db in
                                if try !db.tableExists("media") {
                                    try db.create(table: "media") { t in
                                        t.primaryKey("id", .text)
                                        t.column("moduleID", .text).notNull()
                                        t.column("image", .text).notNull()
                                        t.column("current", .double).notNull()
                                        t.column("duration", .double).notNull()
                                        t.column("title", .text).notNull()
                                        t.column("description", .text)
                                        t.column("mediaUrl", .text).notNull()
                                        t.column("number", .double).notNull()
                                    }
                                }
                                if try !db.tableExists("collection") {
                                    try db.create(table: "collection") { t in
                                        t.primaryKey("id", .text)
                                        t.column("name", .text).notNull()
                                        t.column("items", .jsonText).notNull()
                                    }
                                }
                            }
                            
                            /*
                            try dbQueue.write { db in
                                try Media(
                                    moduleID: "28d8c6c4-335a-11ee-be56-0242ac120002",
                                    image: InfoData.img,
                                    current: 0.5,
                                    duration: 1.0,
                                    title: "Title",
                                    description: "Description",
                                    mediaUrl: "",
                                    number: 1.0
                                ).insert(db)
                            }
                            */
                            state.mediaItems = try dbQueue.read { db in
                                try Media.fetchAll(db)
                            }
                            for item in state.mediaItems {
                                print(item.image)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    return .merge(
                        .run { send in
                            let videoUrlStream = dataClient.observeVideoUrl()
                            let indexStream = dataClient.observeVideoIndex()
                            var valueIterator = videoUrlStream.makeAsyncIterator()
                            var indexIterator = indexStream.makeAsyncIterator()

                            while let value = await valueIterator.next(), let index = await indexIterator.next() {
                                await send(.view(.setVideoUrl(value, index: index)))
                            }
                        }
                    )
                case .setVideoUrl(let url, let index):
                    state.videoUrl = url
                    state.videoIndex = index
                    if let url, !url.isEmpty, let index {
                        state.player = PlayerFeature.State(url: url, index: index)
                        state.showPlayer = true
                    }
                    return .none
                case .changeTab(let tab):
                    state.selected = tab
                    return .none
                case .toggleTabbar:
                    state.showTabbar.toggle()
                    return .none
                case .updateMediaItems(let items):
                    state.mediaItems = items
                    return .none
                }
            case let .internal(internalAction):
                switch internalAction {
                case .more:
                    return .none
                case .discover(.view(.setSearchVisible(let newValue))):
                    if newValue {
                        withAnimation {
                            state.showTabbar = false
                        }
                    } else {
                        withAnimation {
                            state.showTabbar = true
                        }
                    }
                    return .none
                case .discover:
                    return .none
                case .player(.view(.setPiP(let value))):
                    state.showPlayer = !value
                    return .none
                case .player(.view(.setFullscreen(let value))):
                    state.fullscreen = value
                    print(value)
                    return .none
                case .player(.view(.navigateBack)):
                    state.showPlayer = false
                    state.videoUrl = nil
                    state.videoIndex = nil
                    return .none
                case .player:
                    return .none
                case .sheet:
                    return .none
                }
            }
        }
    }
}
