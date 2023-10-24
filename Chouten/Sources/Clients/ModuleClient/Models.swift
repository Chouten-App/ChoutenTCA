//
//  File.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

import Foundation

public struct Module: Hashable, Equatable, Codable, Sendable {
    public let id: String
    public let type: String
    public let subtypes: [String]
    public var icon: String?
    public let name: String
    public let version: String
    public let formatVersion: Int
    public let updateUrl: String
    public let general: GeneralMetadata
}

public struct GeneralMetadata: Hashable, Equatable, Codable, Sendable {
    public let author: String
    public let description: String
    public let lang: [String]
    public let baseURL: String
    public let bgColor: String
    public let fgColor: String
}
