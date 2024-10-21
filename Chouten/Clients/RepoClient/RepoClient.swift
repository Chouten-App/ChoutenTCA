//
//  Client.swift
//
//
//  Created by ErrorErrorError on 7/28/23.
//
//

import Dependencies
import DependenciesMacros
import Foundation
import OSLog

// MARK: - RelayClient

@DependencyClient
struct RepoClient: Sendable {
    var fetchRepoDetails: @Sendable (_ url: URL) async throws -> RepoMetadata?

    var installRepo: @Sendable (_ url: URL) async throws -> Void
    var installRepoMetadata: @Sendable (_ metadata: RepoMetadata) throws -> Void
    var installModule: @Sendable (_ repoMetadata: RepoMetadata, _ id: String) async throws -> Void

    var deleteRepo: @Sendable (_ id: String) throws -> Void
    var deleteModule: @Sendable (_ id: String) throws -> Void

    var getRepo: @Sendable (_ id: String) throws -> RepoMetadata
    var getRepos: @Sendable () throws -> [RepoMetadata]
    var getModulesForRepo: @Sendable (_ id: String) throws -> [Module]
    var getModuleData: @Sendable (_ id: String) throws -> Module

    var getModulePathForId: @Sendable (_ id: String) throws -> URL?
}

extension DependencyValues {
  var repoClient: RepoClient {
    get { self[RepoClient.self] }
    set { self[RepoClient.self] = newValue }
  }
}
