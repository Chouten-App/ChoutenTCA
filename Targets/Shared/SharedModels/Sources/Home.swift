//
//  Home.swift
//
//
//  Created by Eltik on 7/30/24.
//

import Foundation

public enum ItemStatus: String, Codable {
    case inprogress = "In-Progress"
    case completed = "Completed"
    case planned = "Planned"
    case dropped = "Dropped"
    case none = "None"
}

public struct HomeSection: Codable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let type: Int // 0 = Carousel, 1 = List
    public var list: [HomeData]

    public init(id: String, title: String, type: Int, list: [HomeData]) {
        self.id = id
        self.title = title
        self.type = type
        self.list = list
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(type)
    }
}

public struct HomeSectionChecks: Codable, Equatable, Hashable {
    public let id: String
    public let url: String
    public var isInCollection: Bool

    public init(id: String, url: String, isInCollection: Bool) {
        self.id = id
        self.url = url
        self.isInCollection = isInCollection
    }
}

public struct HomeData: Codable, Equatable, Hashable {
    public let id: String
    public let url: String
    public var status: ItemStatus
    public let titles: Titles
    public let poster: String
    public let description: String
    public let label: Label
    public let indicator: String
    public let isWidescreen: Bool
    public let current: Int?
    public let total: Int?
    
    public init(id: String = UUID().uuidString, url: String, titles: Titles, description: String, poster: String, label: Label, indicator: String, status: ItemStatus = .none, isWidescreen: Bool = false, current: Int?, total: Int?) {
        self.id = id
        self.url = url
        self.titles = titles
        self.description = description
        self.poster = poster
        self.label = label
        self.indicator = indicator
        self.isWidescreen = isWidescreen
        self.current = current
        self.total = total
        self.status = status
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(url)
        hasher.combine(titles)
        hasher.combine(poster)
        hasher.combine(description)
        hasher.combine(label)
        hasher.combine(indicator)
    }
    
    public static func == (lhs: HomeData, rhs: HomeData) -> Bool {
        return lhs.id == rhs.id
    }
}
