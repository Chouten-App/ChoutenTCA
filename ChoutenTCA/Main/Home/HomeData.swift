//
//  HomeData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import Foundation

struct HomeComponent: Codable, Equatable {
    let type: String
    let title: String
    let data: [HomeData]
}

struct HomeData: Codable, Equatable {
    let url: String
    let titles: Titles
    let image: String
    let subtitle: String
    let subtitleValue: [String]
    let buttonText: String
    let iconText: String?
    let showIcon: Bool
    let indicator: String?
    let current: Int?
    let total: Int?
}
