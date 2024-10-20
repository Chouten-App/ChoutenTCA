//
//  DiscoverData.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

struct DiscoverData: Codable, Equatable, Hashable {
    let url: String
    let titles: Titles
    let poster: String
    let description: String
    let label: Label
    let indicator: String
    let isWidescreen: Bool
    let current: Int?
    let total: Int?

    var sanitizedDescription: String {
        let regexPattern = "<[^>]+>"

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: description.count)
            let cleanedString = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "")
            return cleanedString
        } catch {
            return description
        }
    }

    init(url: String, titles: Titles, description: String, poster: String, label: Label, indicator: String, isWidescreen: Bool = false, current: Int?, total: Int?) {
        self.url = url
        self.titles = titles
        self.description = description
        self.poster = poster
        self.label = label
        self.indicator = indicator
        self.isWidescreen = isWidescreen
        self.current = current
        self.total = total
    }

    init?(jsValue: JSValue) {
        guard
            let url = jsValue["url"]?.toString(),
            let titles = jsValue["titles"],
            let poster = jsValue["poster"]?.toString(),
            let description = jsValue["description"]?.toString(),
            let label = jsValue["label"],
            let indicator = jsValue["indicator"]?.toString(),
            let titlesValue = Titles(jsValue: titles),
            let labelValue = Label(jsValue: label)
        else {
            return nil
        }

        let isWidescreen = jsValue["isWidescreen"]?.toBool()

        let current = jsValue["current"]?.toInt32()
        let total = jsValue["total"]?.toInt32()

        // let iconText = jsValue["iconText"]?.toString()

        self.url = url
        self.titles = titlesValue
        self.description = description
        self.poster = poster
        self.label = labelValue
        self.indicator = indicator
        self.isWidescreen = isWidescreen ?? false
        // swiftlint:disable force_unwrapping
        self.current = current != nil ? Int(current!) : nil
        self.total = total != nil ? Int(total!) : nil
        // swiftlint:enable force_unwrapping
    }
}
