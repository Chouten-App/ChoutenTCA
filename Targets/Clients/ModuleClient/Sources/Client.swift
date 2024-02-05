//
//  Client.swift
//
//
//  Created by Inumaki on 17.10.23.
//

import Dependencies
import DependenciesMacros
import Foundation
import OSLog
import SharedModels

// MARK: - ModuleClient

@DependencyClient
public struct ModuleClient: Sendable {
  public var importFromFile: @Sendable (_ fileUrl: URL) throws -> Void
  public var getCurrentModule: @Sendable () -> Module?
  public var setCurrentModule: @Sendable (_ module: Module) -> Void
  public var getModules: @Sendable () throws -> [Module]
  public var getMetadata: @Sendable (_ folderUrl: URL) -> Module?
  public var getJs: @Sendable (_ for: String) throws -> String?
  public var deleteModule: @Sendable (_ module: Module) throws -> Bool
  public var setSelectedModuleName: @Sendable (_ module: Module) -> Void
}

extension DependencyValues {
  public var moduleClient: ModuleClient {
    get { self[ModuleClient.self] }
    set { self[ModuleClient.self] = newValue }
  }
}
