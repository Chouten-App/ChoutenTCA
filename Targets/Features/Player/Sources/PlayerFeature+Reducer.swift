//
//  PlayerFeature+Reducer.swift
//
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture
import DataClient
import Foundation
import ModuleClient
import SharedModels
import Webview

extension PlayerFeature: Reducer {
  public var body: some ReducerOf<Self> {
    Scope(state: \.webviewState, action: /Action.InternalAction.webview) {
      WebviewFeature()
    }

    Reduce { state, action in
      switch action {
      case let .view(viewAction):
        switch viewAction {
        case .setPiP:
          return .none
        case let .setSpeed(value):
          state.speed = value
          return .none
        case let .setServer(value):
          state.server = value
          return .none
        case let .setQuality(value):
          state.quality = value
          return .none
        case let .setShowMenu(value):
          state.showMenu = value
          return .none
        case let .setFullscreen(value):
          state.fullscreen = value
          return .none
        case .navigateBack:
          return .none
        case let .setInfoData(data):
          state.infoData = data
          return .none
        case .toggleUI:
          state.showUI.toggle()
          return .none
        case .onAppear:
          if state.infoData == nil {
            state.infoData = dataClient.getInfoData()
          }
          state.videoLoadable = .pending

          state.videoLoadable = .loading

          // TODO: get current selected module
          let module = moduleClient.getCurrentModule()

          if let module {
            moduleClient.setSelectedModuleName(module)

            state.module = module

            do {
              let js = try moduleClient.getJs("media") ?? ""

              return .merge(
                .send(.internal(.webview(.view(.setHtmlString(newString: AppConstants.defaultHtml))))),
                .send(.internal(.webview(.view(.setJsString(newString: js))))),
                .send(.internal(.webview(.view(.setRequestType(type: "media")))))
              )
            } catch {
              state.videoLoadable = .failed(VideoLoadingError.other(error))
              // logger.error("\(error.localizedDescription)")
            }
          } else {
            state.videoLoadable = .failed(VideoLoadingError.other("No Module Selected."))
          }
          return .none
        case let .parseResult(data):
          if let jsonData = data.data(using: .utf8) {
            do {
              let decoder = JSONDecoder()
              let data = try decoder.decode([ServerData].self, from: jsonData)

              return .send(.view(.setServers(data: data)))
            } catch {
              print("Error decoding JSON ODSFG:", error)
              state.videoLoadable = .failed(error)
            }
          } else {
            print("Invalid JSON string")
            state.videoLoadable = .failed(VideoLoadingError.dataParsingError("Invalid JSON string"))
            // state.searchLoadable = .failed()
          }
          return .none
        case let .parseVideoResult(data):
          if let jsonData = data.data(using: .utf8) {
            do {
              let decoder = JSONDecoder()
              let data = try decoder.decode(VideoData.self, from: jsonData)

              return .send(.view(.setVideoData(data: data)))
            } catch {
              print("Error decoding JSON ODSFG:", error)
              state.videoLoadable = .failed(error)
            }
          } else {
            print("Invalid JSON string")
            state.videoLoadable = .failed(VideoLoadingError.dataParsingError("Invalid JSON string"))
            // state.searchLoadable = .failed()
          }
          return .none
        case let .setServers(data):
          state.servers = data
          return .none
        case let .setVideoData(data):
          state.videoLoadable = .loaded(data)

          let dict = data.sources.reduce(into: [String: String]()) { result, source in
            result[source.quality] = source.file
          }

          return .send(.view(.setQualityDict(dict)))
        case .resetWebviewChange:
          return .merge(
            .send(.internal(.webview(.view(.setHtmlString(newString: ""))))),
            .send(.internal(.webview(.view(.setJsString(newString: ""))))),
            .send(.view(.onAppear))
          )
        case let .setQualityDict(dict):
          state.qualities = dict

          state.quality = dict.filter { (key: String, _: String) in
            key.lowercased() == "auto"
          }.first?.key ?? ""
          return .none
        case let .setCurrentItem(data):
          let sourceDict = data.sources.reduce(into: [String: String]()) { dict, source in
            dict[source.quality] = source.file
          }
          state.qualities = sourceDict

          // let item = AVPlayerItem(url: URL(string: viewStore.qualities[viewStore.quality] ?? "")!)

          var subs: [VideoCompositionItem.SubtitleINTERNAL] = []

          if !data.subtitles.isEmpty {
            let sub = data.subtitles.filter { $0.language.lowercased().contains("english") }[0]

            subs.append(VideoCompositionItem.SubtitleINTERNAL(
              name: sub.language,
              default: true,
              autoselect: true,
              link: URL(string: sub.url).unsafelyUnwrapped
            ))
          }

          if !state.qualities.contains(where: { (key: String, _: String) in
            key.lowercased() == "auto"
          }) {
            state.quality = Array(state.qualities.keys)[0]
          }

          if let url = URL(string: state.qualities[state.quality] ?? "") {
            let videoCompItem = VideoCompositionItem(
              link: url,
              headers: data.headers ?? [:],
              subtitles: subs
            )

            state.item = PlayerItem(videoCompItem)
          } else {
            state.videoLoadable = .failed(VideoLoadingError.invalidURL)
          }
          return .none
        case let .setLoadable(loadableState):
          state.videoLoadable = loadableState
          return .none
        }
      case let .internal(internalAction):
        switch internalAction {
        case .webview:
          return .none
        }
      }
    }
  }
}
