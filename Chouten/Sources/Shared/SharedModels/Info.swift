//
//  File.swift
//  
//
//  Created by Inumaki on 21.10.23.
//

import Foundation

public struct InfoData: Codable, Equatable, Sendable {
    public let id: String
    public let titles: Titles
    public let altTitles: [String]
    public let epListURLs: [String]
    public let description: String
    public let poster: String
    public let banner: String?
    public let status: String?
    public let totalMediaCount: Int?
    public let mediaType: String
    public let seasons: [SeasonData]
    public var mediaList: [MediaList]
    
    public init(id: String, titles: Titles, altTitles: [String], epListURLs: [String], description: String, poster: String, banner: String?, status: String?, totalMediaCount: Int?, mediaType: String, seasons: [SeasonData], mediaList: [MediaList]) {
        self.id = id
        self.titles = titles
        self.altTitles = altTitles
        self.epListURLs = epListURLs
        self.description = description
        self.poster = poster
        self.banner = banner
        self.status = status
        self.totalMediaCount = totalMediaCount
        self.mediaType = mediaType
        self.seasons = seasons
        self.mediaList = mediaList
    }
    
    public static let sample = InfoData(
        id: "",
        titles: Titles(primary: "Primary", secondary: "Secondary"),
        altTitles: [],
        epListURLs: [],
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
        banner: nil,
        status: "Finished",
        totalMediaCount: 12,
        mediaType: "Episodes",
        seasons: [],
        mediaList: []
    )
}

public struct SeasonData: Codable, Equatable, Sendable {
    public let name: String
    public let url: String
}

public struct MediaList: Codable, Equatable, Sendable {
    public let title: String
    public var list: [MediaItem]
}

public struct MediaItem: Codable, Equatable, Hashable, Sendable {
    public let url: String
    public let number: Double
    public let title: String?
    public let description: String?
    public let image: String?
}

public struct Titles: Codable, Equatable, Sendable {
    public let primary: String
    public let secondary: String?
    
    public init(primary: String, secondary: String?) {
        self.primary = primary
        self.secondary = secondary
    }
}
