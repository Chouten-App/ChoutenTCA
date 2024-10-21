//
//  Repo.swift
//  SharedModels
//
//  Created by Inumaki on 10.06.24.
//

import Foundation

struct RepoMetadata: Codable, Equatable {
    var url: String? = ""
    let id: String
    let title: String
    let author: String
    let description: String
    let modules: [RepoModule]?

    init(id: String, title: String, author: String, description: String, modules: [RepoModule]?) {
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.modules = modules
    }
}
