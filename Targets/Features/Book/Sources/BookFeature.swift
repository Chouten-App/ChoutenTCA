//
//  BookFeature.swift
//  Book
//
//  Created by Inumaki on 20.07.24.
//

import Architecture
import Combine
import RelayClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct BookFeature: Reducer {
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    public struct State: FeatureState {
        public var infoData: InfoData
        public var item: MediaItem
        public var index: Int
        public var mediaItems: [MediaItem]
        public var chapters: [Double: [ImageModel]] = [:]
        public var lastAppendedChapter: [ImageModel] = []

        public init(infoData: InfoData, item: MediaItem, index: Int, mediaItems: [MediaItem]) {
            self.infoData = infoData
            self.item = item
            self.index = index
            self.mediaItems = mediaItems
        }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear
            case appendChapter(_ data: [ImageModel])
            case loadChapter(url: String, number: Double)
        }

        @CasePathable
        @dynamicMemberLookup
        public enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        public enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    public init() { }

    @ReducerBuilder<State, Action> public var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case let .view(viewAction):
          switch viewAction {
          case .onAppear:
              return .send(.view(.loadChapter(url: state.item.url, number: state.item.number)))
          case let .loadChapter(url, number):
              if state.chapters[number] != nil { return .none }
              return .merge(
                  .run { send in
                      do {
                          let chapterData = try await relayClient.pages(url: url)
                          let chapter = chapterData.map { ImageModel(url: $0, chapter: number) }
                          await send(.view(.appendChapter(chapter)))
                      } catch {
                          print(error.localizedDescription)
                      }
                  }
              )
          case .appendChapter(let data):
              state.lastAppendedChapter = data
              if let chapterNumber = data.first?.chapter {
                  print("appended")
                  state.chapters[chapterNumber] = data
              }
              return .none
          }
        }
      }
    }
}
