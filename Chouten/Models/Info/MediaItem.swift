//
//  MediaItem.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct MediaItem: Codable, Equatable, Hashable, Sendable {
     let url: String
     let number: Double
     let title: String?
     let thumbnail: String?
     let description: String?
     let indicator: String?
     var isWatched = false

     var sanitizedDescription: String? {
        let regexPattern = "<[^>]+>"

        if let description {
            do {
                let regex = try NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
                let range = NSRange(location: 0, length: description.count)
                let cleanedString = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "")
                return cleanedString
            } catch {
                return description
            }
        } else {
            return description
        }
    }

     init(url: String, number: Double, title: String? = nil, thumbnail: String? = nil, description: String? = nil, indicator: String? = nil, isWatched: Bool = false) {
        self.url = url
        self.number = number
        self.title = title
        self.thumbnail = thumbnail
        self.description = description
        self.indicator = indicator
        self.isWatched = isWatched
    }

     static let sample = Self(url: "", number: 1.0, title: "Title", thumbnail: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg", description: "Description")
}

extension MediaItem {
     init?(jsValue: JSValue) {
        guard
            let url = jsValue["url"]?.toString(),
            let number = jsValue["number"]?.toDouble()
        else {
            return nil
        }

        let title = jsValue["title"]?.toString()
        let indicator = jsValue["indicator"]?.toString()
        let description = jsValue["description"]?.toString()
        let image = jsValue["thumbnail"]?.toString()

        self.init(url: url, number: number, title: title, thumbnail: image, description: description, indicator: indicator)
    }
}
