//
//  File.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

import Dependencies
import Foundation

public struct FileClient: Sendable {
    public let getModulesFolder: () -> Void
}

public extension DependencyValues {
    var fileClient: FileClient {
        get { self[FileClient.self] }
        set { self[FileClient.self] = newValue }
    }
}
