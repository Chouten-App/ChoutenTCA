//
//  InfoData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation

struct InfoData: Codable, Equatable {
    let id: String
    let titles: Titles
    let altTitles: [String]
    let description: String
    let poster: String
    let banner: String?
    let status: String?
    let totalMediaCount: Int?
    let mediaType: String
    let seasons: [SeasonData]
    var mediaList: [MediaList]
}

struct SeasonData: Codable, Equatable {
    let name: String
    let url: String
}

struct MediaList: Codable, Equatable {
    let title: String
    var list: [MediaItem]
}

struct MediaItem: Codable, Equatable {
    let url: String
    let number: Double
    let title: String?
    let description: String?
    let image: String?
}

struct Titles: Codable, Equatable {
    let primary: String
    let secondary: String?
}
