//
//  SearchData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation

struct SearchData: Codable, Hashable, Equatable {
    let url: String
    let img: String
    let title: String
    let indicatorText: String?
    let currentCount: Int?
    let totalCount: Int?
}

/*
struct SearchResult: Codable, Equatable {
    let currentPage: Int
    let hasNextPage: Bool
    let results: [SearchData]
}

struct SearchData: Codable, Equatable, Identifiable {
    let id: String
    let malId: Int
    let title: Title
    let status: String
    let image: String
    let cover: String?
    let popularity: Int
    let description: String
    let rating: Int?
    let genres: [String]
    let color: String
    var totalEpisodes: Int?
    var currentEpisodeCount: Int?
    let type: String
    let releaseDate: Int?
}

extension SearchResult {
    static var sample: SearchResult {
        SearchResult(
            currentPage: 1,
            hasNextPage: false,
            results: [
                SearchData(
                    id: "101922",
                    malId: 38000,
                    title: Title(
                        english: "Kimetsu no Yaiba",
                        native: "Demon Slayer: Kimetsu no Yaiba",
                        romaji: "鬼滅の刃",
                        userPreferred: "Kimetsu no Yaiba"
                    ),
                    status: "Completed",
                    image: "poster",
                    cover: "https://s4.anilist.co/file/anilistcdn/media/anime/banner/101922-YfZhKBUDDS6L.jpg",
                    popularity: 627348,
                    description: "It is the Taisho Period in Japan. Tanjiro, a kindhearted boy who sells charcoal for a living, finds his family slaughtered by a demon. To make matters worse, his younger sister Nezuko, the sole survivor, has been transformed into a demon herself. Though devastated by this grim reality, Tanjiro resolves to become a “demon slayer” so that he can turn his sister back into a human, and kill the demon that massacred his family.<br>\n<br>\n(Source: Crunchyroll)",
                    rating: 84,
                    genres: [
                        "Action",
                        "Adventure",
                        "Drama",
                        "Fantasy",
                        "Supernatural"
                    ],
                    color: "#4B4A95",
                    totalEpisodes: 26,
                    currentEpisodeCount: 26,
                    type: "TV",
                    releaseDate: 2019
                )
            ]
        )
    }
}
*/
