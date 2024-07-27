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

    // general source module functions
    public var info: @Sendable (_ url: String) async throws -> InfoData
    public var search: @Sendable (_ url: String, _ page: Int) async throws -> SearchResult
    public var discover: @Sendable () async throws -> [DiscoverSection]
    public var media: @Sendable (_ url: String) async throws -> [MediaList]

    // video content functions
    public var sources: @Sendable (_ url: String) async throws -> [SourceList]
    public var streams: @Sendable (_ url: String) async throws -> MediaStream

    // book content functions
    public var pages: @Sendable (_ url: String) async throws -> [String]

    public var importFromFile: @Sendable (_ fileUrl: URL) throws -> Void
    public var getCurrentModuleType: @Sendable () throws -> ModuleType
}

extension DependencyValues {
  public var relayClient: RelayClient {
    get { self[RelayClient.self] }
    set { self[RelayClient.self] = newValue }
  }
}
