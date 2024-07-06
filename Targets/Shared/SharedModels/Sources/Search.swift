//
//  Search.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Foundation
import JavaScriptCore

public struct SearchResultInfo: Codable, Equatable {
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

public struct SearchResult: Codable, Equatable {
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
            guard let url = searchItem["url"] as? String,
                  let title = searchItem["title"] as? String,
                  let img = searchItem["poster"] as? String,
                  let indicatorText = searchItem["indicator"] as? String else {
                continue
            }

            let currentCount = searchItem["current"] as? Int
            let totalCount = searchItem["total"] as? Int

            let value = SearchData(
                url: url,
                img: img,
                title: title,
                indicatorText: indicatorText,
                currentCount: currentCount ?? -1,
                totalCount: totalCount ?? -1
            )
            searchDataArray.append(value)
        }

        self.init(info: info, results: searchDataArray)
    }
}

public struct SearchData: Codable, Equatable {
    public let url: String
    public let img: String
    public let title: String
    public let indicatorText: String
    public let currentCount: Int
    public let totalCount: Int

    public init(url: String, img: String, title: String, indicatorText: String, currentCount: Int, totalCount: Int) {
        self.url = url
        self.img = img
        self.title = title
        self.indicatorText = indicatorText
        self.currentCount = currentCount
        self.totalCount = totalCount
    }

    public init?(jsValue: JSValue) {
        guard
            let url = jsValue["url"]?.toString(),
            let img = jsValue["img"]?.toString(),
            let title = jsValue["title"]?.toString(),
            let indicatorText = jsValue["indicatorText"]?.toString(),
            let currentCount = jsValue["currentCount"]?.toInt32(),
            let totalCount = jsValue["totalCount"]?.toInt32()
        else {
            return nil
        }

        self.url = url
        self.img = img
        self.title = title
        self.indicatorText = indicatorText
        self.currentCount = Int(currentCount)
        self.totalCount = Int(totalCount)
    }

    public static let sample = Self(
        url: "",
        img: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
        title: "Title",
        indicatorText: "Text",
        currentCount: 1,
        totalCount: 12
    )
}
