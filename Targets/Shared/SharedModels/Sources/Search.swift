//
//  Search.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Foundation
import JavaScriptCore

public struct SearchResultInfo: Codable, Equatable, Hashable {
    public var count: Int?
    public var pages: Int
    public var next: String?

    public init(count: Int? = nil, pages: Int, next: String? = nil) {
        self.count = count
        self.pages = pages
        self.next = next
    }

    public init?(jsValue: JSValue) {
        guard let pages = jsValue["pages"]?.toInt32() else {
            return nil
        }

        let convertedPages = Int(pages)

        let count = jsValue["count"]?.toInt32() as? Int
        let next = jsValue["next"]?.toString()


        self.init(count: count, pages: convertedPages, next: next)
    }
}

public struct SearchResult: Codable, Equatable, Hashable {
    public var info: SearchResultInfo
    public var results: [SearchData]

    public init(info: SearchResultInfo, results: [SearchData]) {
        self.info = info
        self.results = results
    }

    public init?(jsValue: JSValue) {
        guard
            let infoValue = jsValue["info"]
        else {
            print("missing info value")
            return nil
        }

        guard let info = SearchResultInfo(jsValue: infoValue) else {
            print("conversion of info failed")
            return nil
        }

        guard let dataArray = jsValue["results"]?.toArray() as? [[String: Any]] else {
            return nil
        }

        var searchDataArray: [SearchData] = []
        for searchItem in dataArray {
            print(searchItem["url"])
            guard let url = searchItem["url"] as? String,
                  let titlesValue = searchItem["titles"] as? [String: String],
                  let primaryTitle = titlesValue["primary"],
                  let poster = searchItem["poster"] as? String,
                  let indicatorText = searchItem["indicator"] as? String else {
                continue
            }

            let titles = Titles(primary: primaryTitle, secondary: titlesValue["secondary"])

            let currentCount = searchItem["current"] as? Int
            let totalCount = searchItem["total"] as? Int

            let value = SearchData(
                url: url,
                poster: poster,
                titles: titles,
                indicator: indicatorText,
                current: currentCount,
                total: totalCount
            )
            searchDataArray.append(value)
        }

        self.init(info: info, results: searchDataArray)
    }
}

public struct SearchData: Codable, Equatable, Hashable {
    public let id: UUID
    public let url: String
    public let poster: String
    public let titles: Titles
    public let indicator: String
    public let current: Int?
    public let total: Int?

    public init(url: String, poster: String, titles: Titles, indicator: String, current: Int?, total: Int?) {
        self.id = UUID()
        self.url = url
        self.poster = poster
        self.titles = titles
        self.indicator = indicator
        self.current = current
        self.total = total
    }

    public init?(jsValue: JSValue) {
        guard
            let url = jsValue["url"]?.toString(),
            let poster = jsValue["poster"]?.toString(),
            let titlesValue = jsValue["titles"],
            let titles = Titles(jsValue: titlesValue),
            let indicator = jsValue["indicator"]?.toString()
        else {
            print("Failed to convert Search data.")
            return nil
        }

        let current = jsValue["current"]?.toInt32()
        let total = jsValue["total"]?.toInt32()

        self.id = UUID()

        self.url = url
        self.poster = poster
        self.titles = titles
        self.indicator = indicator
        // swiftlint:disable force_unwrapping
        self.current = current != nil ? Int(current!) : nil
        self.total = total != nil ? Int(total!) : nil
        // swiftlint:enable force_unwrapping
    }

    public static let sample = Self(
        url: "",
        poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
        titles: Titles(primary: "Title", secondary: nil),
        indicator: "Text",
        current: 1,
        total: 12
    )
}
