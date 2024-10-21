//
//  HomeData.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Combine
import Foundation

struct HomeData: Codable, Equatable, Hashable {
    let id: String
    let url: String
    var status: ItemStatus
    let titles: Titles
    let poster: String
    let description: String
    let label: Label
    let indicator: String
    let isWidescreen: Bool
    let current: Int?
    let total: Int?
    
    init(id: String = UUID().uuidString, url: String, titles: Titles, description: String, poster: String, label: Label, indicator: String, status: ItemStatus = .none, isWidescreen: Bool = false, current: Int?, total: Int?) {
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(url)
        hasher.combine(titles)
        hasher.combine(poster)
        hasher.combine(description)
        hasher.combine(label)
        hasher.combine(indicator)
    }
    
    static func == (lhs: HomeData, rhs: HomeData) -> Bool {
        return lhs.id == rhs.id
    }
}
