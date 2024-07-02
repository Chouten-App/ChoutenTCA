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
import SharedModels

// MARK: - RelayClient

@DependencyClient
public struct RepoClient: Sendable {
    public var fetchRepoDetails: @Sendable (_ url: URL) async throws -> RepoMetadata?

    public var installRepo: @Sendable (_ url: URL) async throws -> Void
    public var installRepoMetadata: @Sendable (_ metadata: RepoMetadata) throws -> Void
    public var installModule: @Sendable (_ repoMetadata: RepoMetadata, _ id: String) async throws -> Void

    public var deleteRepo: @Sendable (_ id: String) throws -> Void
    public var deleteModule: @Sendable (_ id: String) throws -> Void

    public var getRepo: @Sendable (_ id: String) throws -> RepoMetadata
    public var getRepos: @Sendable () throws -> [RepoMetadata]
    public var getModulesForRepo: @Sendable (_ id: String) throws -> [Module]
    public var getModuleData: @Sendable (_ id: String) throws -> Module

    public var getModulePathForId: @Sendable (_ id: String) throws -> URL?
}

extension DependencyValues {
  public var repoClient: RepoClient {
    get { self[RepoClient.self] }
    set { self[RepoClient.self] = newValue }
  }
}
