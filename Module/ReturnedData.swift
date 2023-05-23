//
//  ReturnedData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation

struct ReturnedData: Codable {
    let request: Request?
    let usesApi: Bool
    let allowExternalScripts: Bool
    let removeScripts: Bool
    let imports: [String]
    let js: String
}

struct StringReturn: Codable {
    let request: Request?
    var usesApi: Bool = false
    let allowExternalScripts: Bool
    let removeScripts: Bool
    var imports: [String] = []
}

struct Request: Hashable, Equatable, Codable {
    let url: String
    let type: String
    let headers: [Header]
    let body: String?
}

struct Header: Hashable, Equatable, Codable {
    let key: String
    let value: String
}
