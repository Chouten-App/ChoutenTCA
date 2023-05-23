//
//  Module.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation

struct Module: Hashable, Equatable, Codable {
    let id: String
    let type: String
    let subtypes: [String]
    var icon: String?
    let name: String
    let version: String
    let formatVersion: Int
    let updateUrl: String
    let general: GeneralMetadata
}

struct GeneralMetadata: Hashable, Equatable, Codable {
    let author: String
    let description: String
    let lang: [String]
    let baseURL: String
    let bgColor: String
    let fgColor: String
}
