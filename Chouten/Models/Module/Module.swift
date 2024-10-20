//
//  Module.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Foundation

 struct Module: Hashable, Equatable, Codable, Sendable {
     let id: String
     let name: String
     let author: String
     let description: String
     let type: Int
     let subtypes: [String]
     let version: String
     var state: ModuleState? = .notInstalled

     init(id: String, name: String, author: String, description: String, type: Int, subtypes: [String], version: String, state: ModuleState? = nil) {
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
