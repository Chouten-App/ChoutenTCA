//
//  Module.swift
//  SharedModels
//
//  Created by Inumaki on 23.03.24.
//

import Foundation

public enum ModuleState: Hashable, Equatable, Codable, Sendable {
    case upToDate
    case updateAvailable
    case discontinued
    case notInstalled
}

public struct Module: Hashable, Equatable, Codable, Sendable {
    public let id: String
    public let name: String
    public let author: String
    public let description: String
    public let type: Int
    public let subtypes: [String]
    public let version: String
    public var state: ModuleState? = .notInstalled

    public init(id: String, name: String, author: String, description: String, type: Int, subtypes: [String], version: String, state: ModuleState? = nil) {
        self.id = id
        self.name = name
        self.author = author
        self.description = description
        self.type = type
        self.subtypes = subtypes
        self.version = version
        self.state = state
    }
}

public enum ModuleVersionStatus: Hashable, Equatable, Codable, Sendable {
    case upToDate
    case uninstalled
    case updateAvailable
}

public struct GeneralMetadata: Hashable, Equatable, Codable, Sendable {
    public let author: String
    public let description: String
    public let lang: [String]
    public let baseURL: String
    public let bgColor: String
    public let fgColor: String

    public init(author: String, description: String, lang: [String], baseURL: String, bgColor: String, fgColor: String) {
        self.author = author
        self.description = description
        self.lang = lang
        self.baseURL = baseURL
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
}
