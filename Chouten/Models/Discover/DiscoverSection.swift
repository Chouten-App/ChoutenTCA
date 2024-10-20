//
//  DiscoverSection.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

struct DiscoverSection: Codable, Equatable, Hashable {
    let title: String
    let type: Int // 0 = Carousel, 1 = List
    let list: [DiscoverData]

    init(title: String, type: Int, list: [DiscoverData]) {
        self.title = title
        self.type = type
        self.list = list
    }

    init?(jsValue: JSValue) {
        guard
            let title = jsValue["title"]?.toString(),
            let type = jsValue["type"]?.toInt32(),
            let dataList = jsValue["list"]?.toArray()
        else {
            return nil
        }

        var discoverDataList = [DiscoverData]()
        for dataItem in dataList {
            if let dataJSValue = dataItem as? JSValue, let discoverData = DiscoverData(jsValue: dataJSValue) {
                discoverDataList.append(discoverData)
            }
        }

        self.title = title
        self.type = Int(type)
        self.list = discoverDataList
    }

    static let sampleSection = Self(
        title: "Section",
        type: 0,
        list: [
            DiscoverData(
                url: "",
                titles: Titles(primary: "Primary", secondary: "Secondary"),
                description: """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc semper urna enim, quis
                blandit elit sodales et. Morbi quis tortor a velit ultricies elementum. Morbi auctor
                vitae risus sed fermentum.
                """,
                poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
                label: Label(text: "heart", color: ""),
                indicator: "",
                current: 1,
                total: 12
            )
        ]
    )
}
