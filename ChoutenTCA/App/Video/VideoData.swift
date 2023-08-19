//
//  VideoData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import Foundation

struct ServerData: Codable, Equatable {
    let title: String
    let list: [Server]
}

struct Server: Codable, Hashable, Equatable {
    let name: String
    let url: String
}

struct VideoData: Codable, Equatable {
    let sources: [Source]
    let subtitles: [Subtitle]
    let skips: [SkipTime]
    let headers: [String: String]?
}

struct SkipTime: Codable, Equatable {
    let start: Double
    let end: Double
    let type: String
}

struct Subtitle: Codable, Equatable {
    let url: String
    let language: String
}

struct Source: Codable, Equatable {
    let file: String
    let type: String
    let quality: String
}
