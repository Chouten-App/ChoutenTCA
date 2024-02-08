//
//  AppFeature+Reducer.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import ComposableArchitecture
import Discover
import GRDB
import ModuleSheet
import More
import Player
import SharedModels
import SwiftUI

extension AppFeature {
  @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
    Scope(state: \.more, action: \.internal.more) {
      MoreFeature()
    }

    Scope(state: \.discover, action: \.internal.discover) {
      DiscoverFeature()
    }

    Scope(state: \.player, action: \.internal.player) {
      PlayerFeature()
    }

    Scope(state: \.sheet, action: \.internal.sheet) {
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

          // TODO: Move this to a database client
          // Database
          if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            var isDirectory: ObjCBool = false
            if !FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("Databases").path, isDirectory: &isDirectory) {
              do {
                try FileManager.default.createDirectory(
                  at: documentsDirectory.appendingPathComponent("Databases"), withIntermediateDirectories: false,
                  attributes: nil
                )
                print("Created Database Directory")
              } catch {
                print("Error: \(error)")
              }
            }

            do {
              let dbQueue = try DatabaseQueue(
                path: documentsDirectory
                  .appendingPathComponent("Databases")
                  .appendingPathComponent("chouten.sqlite")
                  .absoluteString
              )

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

              // try dbQueue.write { db in
              //    try Media(
              //        moduleID: "28d8c6c4-335a-11ee-be56-0242ac120002",
              //        image: InfoData.img,
              //        current: 0.5,
              //        duration: 1.0,
              //        title: "Title",
              //        description: "Description",
              //        mediaUrl: "",
              //        number: 1.0
              //    ).insert(db)
              // }
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
        case let .setVideoUrl(url, index):
          state.videoUrl = url
          state.videoIndex = index
          if let url, !url.isEmpty, let index {
            state.player = PlayerFeature.State(url: url, index: index)
            state.showPlayer = true
          }
          return .none
        case let .changeTab(tab):
          state.selected = tab
          return .none
        case .toggleTabbar:
          state.showTabbar.toggle()
          return .none
        case let .updateMediaItems(items):
          state.mediaItems = items
          return .none
        }
      case let .internal(internalAction):
        switch internalAction {
        case .more:
          return .none
        case let .discover(.view(.setSearchVisible(newValue))):
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
        case let .player(.view(.setPiP(value))):
          state.showPlayer = !value
          return .none
        case let .player(.view(.setFullscreen(value))):
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
