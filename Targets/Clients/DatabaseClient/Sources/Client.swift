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
    public let initDB: () async -> Void
    public let createCollection: (_ name: String) async -> String
    public let fetchCollections: () async -> [HomeSection]
    public let fetchCollection: (_ id: String) async -> [MediaItem]
}

extension DependencyValues {
    public var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}
