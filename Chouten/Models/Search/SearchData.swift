//
//  SearchData.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct SearchData: Codable, Equatable, Hashable {
     let id: UUID
     let url: String
     let poster: String
     let titles: Titles
     let indicator: String
     let current: Int?
     let total: Int?

     init(url: String, poster: String, titles: Titles, indicator: String, current: Int?, total: Int?) {
        self.id = UUID()
        self.url = url
        self.poster = poster
        self.titles = titles
        self.indicator = indicator
        self.current = current
        self.total = total
    }

     init?(jsValue: JSValue) {
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

     static let sample = Self(
        url: "",
        poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
        titles: Titles(primary: "Title", secondary: nil),
        indicator: "Text",
        current: 1,
        total: 12
    )
}
