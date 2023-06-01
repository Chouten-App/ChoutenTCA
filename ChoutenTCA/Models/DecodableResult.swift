//
//  DecodableResult.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation

struct DecodableResult<T: Codable>: Codable {
    let result: T
    let nextUrl: String?
}
