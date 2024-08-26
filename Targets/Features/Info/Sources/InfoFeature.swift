//
//  InfoFeature.swift
//  Info
//
//  Created by Inumaki on 25.04.24.
//

import Architecture
import Combine
import DatabaseClient
import RelayClient
import SharedModels
import SwiftUI

@Reducer
public struct InfoFeature: Reducer {
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.relayClient) var relayClient

    @ObservableState
    public struct State: FeatureState {
        // swiftlint:disable redundant_optional_initialization
        public var infoData: InfoData? = nil
        // swiftlint:enable redundant_optional_initialization
        public var doneLoading = false

        public var currentModuleType: ModuleType = .video
        
        public var url: String = ""
        
        public var collections: [HomeSection] = []
        
        public var isInCollections: [HomeSectionChecks] = []
        
        public var isInAnyCollection = false
        
        public var flag: ItemStatus = .none

        public init() { }
    }

    @CasePathable
    @dynamicMemberLookup
    public enum Action: FeatureAction {
        @CasePathable
        @dynamicMemberLookup
        public enum ViewAction: SendableAction {
            case onAppear(_ url: String)
            case fetchMedia(_ url: String)
            case fetchNewSeason(_ url: String, newIndex: Int)
            case setSelectedSeason(_ newIndex: Int, data: [MediaList])
            case setInfoData(_ data: InfoData)
            case setMediaList(_ data: [MediaList])
            case setCurrentModuleType(_ type: ModuleType)
            case setCollections(_ data: [HomeSection])
            case setIsInCollections(_ data: [HomeSectionChecks])
            case updateIsInCollections
            case updateIsInAnyCollection( _ data: Bool)
            case updateFlag(_ flag: ItemStatus)
            case addToCollection(_ section: HomeSection)
            case updateItemInCollection(_ section: HomeSection)
            case removeFromCollection(_ section: HomeSection)
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
                case .onAppear(let url):
                    state.url = url
                    return .merge(
                        .run { send in
                            do {
                                let type = try relayClient.getCurrentModuleType()
                                await send(.view(.setCurrentModuleType(type)))
                                let data = try await self.relayClient.info(url)
                                
                                let collections = await self.databaseClient.fetchCollections();
                                
                                await send(.view(.updateIsInCollections))
                                
                                await send(.view(.setInfoData(data)))
                                await send(.view(.setCollections(collections)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                case .fetchMedia(let url):
                    return .merge(
                        .run { send in
                            do {
                                let data = try await self.relayClient.media(url)
                                await send(.view(.setMediaList(data)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                case let .fetchNewSeason(url, newIndex):
                    return .merge(
                        .run { send in
                            do {
                                let data = try await self.relayClient.media(url)
                                await send(.view(.setSelectedSeason(newIndex, data: data)))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    )
                case let .setSelectedSeason(newIndex, data):
                    if state.infoData != nil {
                        // swiftlint:disable force_unwrapping
                        for index in state.infoData!.seasons.indices {
                            state.infoData!.seasons[index].selected = index == newIndex
                        }
                        // swiftlint:enable force_unwrapping
                    }
                    return .send(.view(.setMediaList(data)))
                case .addToCollection(let section):
                    print("Adding item to collection! Item is \(state.url)")
                    let infoData = CollectionItem(infoData: state.infoData!, url: state.url, flag: state.flag)
                    return .run { send in
                        await self.databaseClient.addToCollection(section.id, "", infoData)
                        await send(.view(.updateIsInCollections))
                    }
                case .updateItemInCollection(let section):
                    print("Updating item in collection! Item is \(state.url)")
                    let infoData = CollectionItem(infoData: state.infoData!, url: state.url, flag: state.flag)
                    return .run { send in
                        await self.databaseClient.updateItemInCollection(section.id, "", infoData)
                        await send(.view(.updateIsInCollections))
                    }
                case .removeFromCollection(let section):
                    print("Removing item from collection! Item is \(state.url)")
                    let infoData = CollectionItem(infoData: state.infoData!, url: state.url, flag: state.flag)
                    return .run { send in
                        await self.databaseClient.removeFromCollection(section.id, "", infoData)
                        await send(.view(.updateIsInCollections))
                    }
                case .setCollections(let data):
                    state.collections = data
                    return .none
                case .setIsInCollections(let data):
                    state.isInCollections = data
                    return .none
                case .updateIsInCollections:
                    state.isInCollections = []
                    
                    let url = state.url
                    return .run { send in
                        let collections = await self.databaseClient.fetchCollections();
                        var isInCollections: [HomeSectionChecks] = []
                        
                        var isInAnyCollection = false
                        
                        for section in collections {
                            let isInCollection = section.list.contains { $0.url == url }
                            if isInCollection {
                                isInAnyCollection = true
                            }
                            
                            isInCollections.append(HomeSectionChecks(id: section.id, url: url, isInCollection: isInCollection))
                        }
                        
                        await send(.view(.updateIsInAnyCollection(isInAnyCollection)))
                        await send(.view(.setIsInCollections(isInCollections)))
                    }
                case .updateIsInAnyCollection(let data):
                    state.isInAnyCollection = data
                    return .none
                case .updateFlag(let flag):
                    state.flag = flag
                    return .none
                case .setInfoData(let data):
                    state.infoData = data
                    
                    if let url = data.seasons.first(where: { $0.selected == true })?.url {
                        return .send(.view(.fetchMedia(url)))
                    } else if let url = data.seasons.first?.url {
                        return .send(.view(.fetchMedia(url)))
                    }

                    state.doneLoading = true

                    return .none
                case .setMediaList(let data):
                    state.infoData?.mediaList = data
                    state.doneLoading = true
                    return .none
                case .setCurrentModuleType(let type):
                    state.currentModuleType = type
                    return .none
                }
            }
        }
    }
}
