//
//  Client.swift
//
//
//  Created by Eltik on 30.7.24.
//

import Dependencies
import Foundation

// MARK: - DatabaseClient

struct DatabaseClient: Sendable {
    let initDB: @Sendable () async -> Void
    
    let fetchCollection: @Sendable (_ id: String) async -> CollectionData?
    let fetchCollections: @Sendable () async -> [HomeSection]
    
    let isInCollection: @Sendable(_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Bool
    
    let createCollection: @Sendable (_ name: String) async -> String
    let addToCollection: @Sendable (_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Void
    let updateItemInCollection: @Sendable (_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Void
    let removeFromCollection: @Sendable (_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Void
    let removeCollection: @Sendable (_ collectionId: String, _ moduleId: String) async -> Void
    
    
    let fetchContinueWatching: @Sendable () async -> HomeSection
    let addToContinueWatching: @Sendable (_ moduleId: String, _ infoData: CollectionItem) async -> Void
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
