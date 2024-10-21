//
//  HomeSection.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Foundation
import Combine

struct HomeSection: Codable, Equatable, Hashable {
    let id: String
    let title: String
    let type: Int // 0 = Carousel, 1 = List
    var list: [HomeData]

    init(id: String, title: String, type: Int, list: [HomeData]) {
        self.id = id
        self.title = title
        self.type = type
        self.list = list
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(type)
    }
}
