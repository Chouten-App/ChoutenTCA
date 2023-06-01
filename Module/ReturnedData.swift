//
//  ReturnedData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation

struct ReturnedData: Codable, Equatable {
    var request: Request?
    var usesApi: Bool = false
    var allowExternalScripts: Bool = false
    var removeScripts: Bool = false
    var imports: [String] = []
    var js: String = ""
}

struct StringReturn: Codable, Equatable {
    let request: Request?
    var usesApi: Bool? = false
    let allowExternalScripts: Bool
    let removeScripts: Bool
    var imports: [String] = []
}

struct Request: Hashable, Equatable, Codable {
    let url: String
    let method: String
    let headers: [Header]
    let body: String?
}

struct Header: Hashable, Equatable, Codable {
    let key: String
    let value: String
}
