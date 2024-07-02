//
//  Repo.swift
//  SharedModels
//
//  Created by Inumaki on 10.06.24.
//

import Foundation

public struct RepoMetadata: Codable, Equatable {
    public var url: String? = ""
    public let id: String
    public let title: String
    public let author: String
    public let description: String
    public let modules: [RepoModule]?

    public init(id: String, title: String, author: String, description: String, modules: [RepoModule]?) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.modules = modules
    }
}

public struct RepoModule: Codable, Equatable {
    public let id: String
    public let name: String
    public let iconPath: String
    public let filePath: String
    public let author: String
    public let version: String
    public let subtypes: [String]
}
