//
//  MediaStream.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

struct MediaStream: Codable, Equatable, Sendable {
    let streams: [Stream]
    let subtitles: [Subtitle]
    let skips: [SkipTime]
    let headers: [String: String]?

    init(streams: [Stream], subtitles: [Subtitle], skips: [SkipTime], headers: [String: String]?) {
        self.streams = streams
        self.subtitles = subtitles
        self.skips = skips
        self.headers = headers
    }

    init(jsValue: JSValue) {
        let streamsValues = jsValue["streams"]?.toStreamsArray()
        self.streams = streamsValues ?? []

        let subtitleValues = jsValue["subtitles"]?.toSubtitlesArray()
        self.subtitles = subtitleValues ?? []

        let skipValues = jsValue["skips"]?.toSkipTimeArray()
        self.skips = skipValues ?? []

        self.headers = nil // jsValue.forProperty("headers")?.toDictionary() as? [String: String]
    }
}
