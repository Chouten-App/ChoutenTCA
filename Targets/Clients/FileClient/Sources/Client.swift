//
//  Client.swift
//
//
//  Created by Inumaki on 17.10.23.
//

import Dependencies
import Foundation

// MARK: - FileClient

public struct FileClient: Sendable {
  public let getModulesFolder: () -> Void
}

extension DependencyValues {
  public var fileClient: FileClient {
    get { self[FileClient.self] }
    set { self[FileClient.self] = newValue }
  }
}
