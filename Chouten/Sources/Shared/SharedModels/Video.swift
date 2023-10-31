//
//  File.swift
//  
//
//  Created by Inumaki on 29.10.23.
//

import Foundation

public struct ServerData: Codable, Equatable {
    public let title: String
    public let list: [Server]
}

public struct Server: Codable, Hashable, Equatable {
    public let name: String
    public let url: String
}

public struct VideoData: Codable, Equatable {
    public let sources: [Source]
    public let subtitles: [Subtitle]
    public let skips: [SkipTime]
    public let headers: [String: String]?
}

public struct SkipTime: Codable, Equatable {
    public let start: Double
    public let end: Double
    public let type: String
}

public struct Subtitle: Codable, Equatable {
    public let url: String
    public let language: String
}

public struct Source: Codable, Equatable {
    public let file: String
    public let type: String
    public let quality: String
}
