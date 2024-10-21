//
//  Repo.swift
//  SharedModels
//
//  Created by Inumaki on 10.06.24.
//

import Foundation

struct RepoModule: Codable, Equatable {
    let id: String
    let name: String
    let iconPath: String
    let filePath: String
    let author: String
    let version: String
    let subtypes: [String]
}
