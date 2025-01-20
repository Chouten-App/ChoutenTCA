//
//  HomeFeature.swift
//  Home
//
//  Created by Inumaki on 19.04.24.
//

import Core
import ComposableArchitecture
import Combine
import SwiftUI

@Reducer
struct HomeFeature: Reducer {
    @Dependency(\.databaseClient) var databaseClient

    @ObservableState
    struct State: FeatureState {
        var collections: [HomeSection] = []

        init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        enum ViewAction: SendableAction {
            case onAppear
            case setCollections(_ data: [HomeSection])
            case createCollection(_ name: String)
            case deleteItem(_ collectionId: String, _ data: HomeData)
            case deleteCollection(_ collectionId: String)
            case updateCollectionName(_ collectionId: String, _ name: String)
        }

        @CasePathable
        @dynamicMemberLookup
        enum DelegateAction: SendableAction {}

        @CasePathable
        @dynamicMemberLookup
        enum InternalAction: SendableAction {}

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }

    init() { }

    @ReducerBuilder<State, Action> var body: some ReducerOf<Self> {
        Reduce { state, action in
        switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onAppear:
                    state.collections = []
                    return .merge(
                        .run { send in
                            await self.databaseClient.initDB()
                            
                            var collections = await self.databaseClient.fetchCollections()
                            let continueWatching = await self.databaseClient.fetchContinueWatching()
                            
                            collections.insert(continueWatching, at: 0)
                            
                            await send(.view(.setCollections(collections)))
                            
                            print("Second *** Collections count: \(collections.count)")
                            print("Collections item: \(String(describing: collections))")
                            print(continueWatching.list)
                        }
                    )
                case .setCollections(let data):
                    state.collections = data
                    return .none
                case .updateCollectionName(let collectionId, let name):
                    return .merge(
                        .run { send in
                            await self.databaseClient.updateCollectionName(collectionId, name)
                        }
                    )
                case .deleteItem(let collectionId, let data):
                    return .run { send in
                        print("Deleting item for \(data.url)")
                        await self.databaseClient.removeFromCollection(
                            collectionId, "",
                            CollectionItem(
                                infoData: InfoData(
                                    titles: data.titles,
                                    tags: [],
                                    description: data.description,
                                    poster: data.poster,
                                    banner: nil,
                                    status: nil,
                                    mediaType: "",
                                    yearReleased: 0,
                                    seasons: [],
                                    mediaList: []
                                ),
                                url: data.url,
                                flag: .none
                            )
                        )
                        await send(.view(.onAppear))
                    }
                case .deleteCollection(let collectionId):
                    return .run { send in
                        print("Deleting collection for \(collectionId).")
                        await self.databaseClient.removeCollection(collectionId, "")
                        await send(.view(.onAppear))
                    }
                case .createCollection(let name):
                    return .run { send in
                        print("Creating collection for \(name)...")
                        
                        let result = await self.databaseClient.createCollection(name)
                        print("Collection created with name \(result)!")
                        await send(.view(.onAppear))
                    }
                }
            }
        }
    }
}
