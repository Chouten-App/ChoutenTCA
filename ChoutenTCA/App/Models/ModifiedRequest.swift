//
//  ModifiedRequest.swift
//  ChoutenTCA
//
//  Created by Inumaki on 04.10.23.
//

import Foundation

struct ModifiedRequest: Codable {
    let url: String
    let options: ModifiedRequestOptions?
}

struct ModifiedRequestOptions: Codable {
    let method: String?
    let headers: [String: String]?
    let body: String?
}
