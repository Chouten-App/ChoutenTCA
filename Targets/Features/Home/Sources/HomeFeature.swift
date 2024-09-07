//
//  HomeFeature.swift
//  Home
//
//  Created by Inumaki on 19.04.24.
//

import Architecture
import Combine
import DatabaseClient
@preconcurrency import SharedModels
import SwiftUI

@Reducer
public struct HomeFeature: Reducer {
    @Dependency(\.databaseClient) var databaseClient

    @ObservableState
    public struct State: FeatureState {
        public var collections: [HomeSection] = []

        public init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear
            case setCollections(_ data: [HomeSection])
            case createCollection(_ name: String)
            case deleteItem(_ collectionId: String, _ data: HomeData)
            case deleteCollection(_ collectionId: String)
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
                    state.collections = []
                    return .merge(
                        .run { send in
                            await self.databaseClient.initDB()
                            
                            var collections = await self.databaseClient.fetchCollections();
                            let continueWatching = await self.databaseClient.fetchContinueWatching();
                            
                            collections.append(continueWatching)
                            
                            await send(.view(.setCollections(collections)))
                            
                            print("Collections count: \(collections.count)")
                            print("Continue watching count: \(continueWatching.list.count)")
                        }
                    )
                case .setCollections(let data):
                    state.collections = data
                    return .none
                case .deleteItem(let collectionId, let data):
                    return .run { send in
                        print("Deleting item for \(data.url)")
                        await self.databaseClient.removeFromCollection(collectionId, "", CollectionItem(infoData: InfoData(titles: data.titles, tags: [], description: data.description, poster: data.poster, banner: nil, status: nil, mediaType: "", yearReleased: 0, seasons: [], mediaList: []), url: data.url, flag: .none))
                    }
                case .deleteCollection(let collectionId):
                    return .run { send in
                        print("Deleting collection for \(collectionId).")
                        await self.databaseClient.removeCollection(collectionId, "");
                    }
                case .createCollection(let name):
                    return .run { _ in
                        print("Creating collection for \(name)...")
                        
                        let result = await self.databaseClient.createCollection(name)
                        print("Collection created with name \(result)!")
                    }
                }
            }
        }
    }
}
