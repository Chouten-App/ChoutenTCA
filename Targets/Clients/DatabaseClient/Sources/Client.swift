//
//  Client.swift
//
//
//  Created by Eltik on 30.7.24.
//

import Dependencies
import Foundation
import SharedModels

// MARK: - DatabaseClient

public struct DatabaseClient: Sendable {
    public let initDB: @Sendable () async -> Void
    public let createCollection: @Sendable (_ name: String) async -> String
    public let fetchCollection: @Sendable (_ id: String) async -> CollectionData?
    public let fetchCollections: @Sendable () async -> [HomeSection]
    public let isInCollection: @Sendable(_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Bool
    public let addToCollection: @Sendable (_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Void
    public let updateItemInCollection: @Sendable (_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Void
    public let removeFromCollection: @Sendable (_ collectionId: String, _ moduleId: String, _ infoData: CollectionItem) async -> Void
    public let removeCollection: @Sendable (_ collectionId: String, _ moduleId: String) async -> Void
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

public struct CollectionData: Codable, Equatable, Hashable {
    let uuid: String;
    let name: String;
}
