//
//  File.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

import Dependencies
import Foundation
import OSLog

public struct ModuleClient: Sendable {
    public static var moduleFolderNames: [String] = []
    public static var moduleIds: [String] = []
    public static var selectedModuleName: String = ""
    public static let minimumFormatVersion: Int = 1
    
    public var importFromFile: @Sendable (_ fileUrl: URL) throws -> Void
    public var getModules: @Sendable () throws -> [Module]
    public var getMetadata: @Sendable (_ folderUrl: URL) -> Module?
    public var getJs: @Sendable (_ for: String) throws -> String?
    public var deleteModule: @Sendable (_ module: Module) throws -> Bool
    public var setSelectedModuleName: @Sendable (_ module: Module) -> Void
}

extension ModuleClient: TestDependencyKey {
    public static let testValue = Self(
        importFromFile: unimplemented(),
        getModules: unimplemented(),
        getMetadata: unimplemented(),
        getJs: unimplemented(),
        deleteModule: unimplemented(),
        setSelectedModuleName: unimplemented()
    )
}

public extension DependencyValues {
    var moduleClient: ModuleClient {
        get { self[ModuleClient.self] }
        set { self[ModuleClient.self] = newValue }
    }
}
