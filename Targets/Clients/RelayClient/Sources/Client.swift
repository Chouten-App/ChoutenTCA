//
//  File.swift
//  
//
//  Created by Inumaki on 19.04.24.
//

import Dependencies
import DependenciesMacros
import Foundation
import OSLog
import SharedModels

// MARK: - RelayClient

@DependencyClient
public struct RelayClient: Sendable {
    public var loadModule: @Sendable (_ fileURL: URL) throws -> Module?
    public var info: @Sendable (_ url: String) async throws -> InfoData
    public var search: @Sendable (_ url: String, _ page: Int) async throws -> SearchResult
    public var discover: @Sendable () async throws -> [DiscoverSection]
    public var media: @Sendable (_ url: String) async throws -> [MediaList]
    public var servers: @Sendable (_ url: String) async throws -> [ServerList]
    public var sources: @Sendable (_ url: String) async throws -> VideoData
    public var importFromFile: @Sendable (_ fileUrl: URL) throws -> Void
}

extension DependencyValues {
  public var relayClient: RelayClient {
    get { self[RelayClient.self] }
    set { self[RelayClient.self] = newValue }
  }
}
