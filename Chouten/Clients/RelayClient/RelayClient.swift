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

// MARK: - RelayClient

@DependencyClient
 struct RelayClient: Sendable {
     var loadModule: @Sendable (_ fileURL: URL) throws -> Module?

    // general source module functions
     var info: @Sendable (_ url: String) async throws -> InfoData
     var search: @Sendable (_ url: String, _ page: Int) async throws -> SearchResult
     var discover: @Sendable () async throws -> [DiscoverSection]
     var media: @Sendable (_ url: String) async throws -> [MediaList]

    // video content functions
     var sources: @Sendable (_ url: String) async throws -> [SourceList]
     var streams: @Sendable (_ url: String) async throws -> MediaStream

    // book content functions
     var pages: @Sendable (_ url: String) async throws -> [String]

     var importFromFile: @Sendable (_ fileUrl: URL) throws -> Void
     var getCurrentModuleType: @Sendable () throws -> ModuleType
}

extension DependencyValues {
   var relayClient: RelayClient {
    get { self[RelayClient.self] }
    set { self[RelayClient.self] = newValue }
  }
}
