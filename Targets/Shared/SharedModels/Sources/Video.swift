//
//  Video.swift
//
//
//  Created by Inumaki on 29.10.23.
//

import Foundation
import JavaScriptCore

// MARK: - ServerData

public struct SourceList: Codable, Equatable, Sendable {
  public let title: String
  public let list: [SourceData]

  public init(title: String, list: [SourceData]) {
    self.title = title
    self.list = list
  }
}

// MARK: - Server

public struct SourceData: Codable, Hashable, Equatable, Sendable {
  public let name: String
  public let url: String

  public init(name: String, url: String) {
    self.name = name
    self.url = url
  }
}

// MARK: - VideoData

public struct MediaStream: Codable, Equatable, Sendable {
    public let streams: [Stream]
    public let subtitles: [Subtitle]
    public let skips: [SkipTime]
    public let headers: [String: String]?

    public init(streams: [Stream], subtitles: [Subtitle], skips: [SkipTime], headers: [String: String]?) {
        self.streams = streams
        self.subtitles = subtitles
        self.skips = skips
        self.headers = headers
    }

    public init(jsValue: JSValue) {
        let streamsValues = jsValue["streams"]?.toStreamsArray()
        self.streams = streamsValues ?? []

        let subtitleValues = jsValue["subtitles"]?.toSubtitlesArray()
        self.subtitles = subtitleValues ?? []

        let skipValues = jsValue["skips"]?.toSkipTimeArray()
        self.skips = skipValues ?? []

        self.headers = nil // jsValue.forProperty("headers")?.toDictionary() as? [String: String]
    }
}

// MARK: - SkipTime

public struct SkipTime: Codable, Equatable, Sendable {
    public let start: Double
    public let end: Double
    public let type: String

    public init(start: Double, end: Double, type: String) {
        self.start = start
        self.end = end
        self.type = type
    }

    public init(jsValue: JSValue) {
        self.start = jsValue["start"]?.toDouble() ?? 0.0
        self.end = jsValue["end"]?.toDouble() ?? 0.0
        self.type = jsValue["type"]?.toString() ?? ""
    }
}

// MARK: - Subtitle

public struct Subtitle: Codable, Equatable, Sendable {
    public let url: String
    public let language: String

    public init(url: String, language: String) {
        self.url = url
        self.language = language
    }

    public init(jsValue: JSValue) {
        self.url = jsValue["url"]?.toString() ?? ""
        self.language = jsValue["language"]?.toString() ?? ""
    }
}

// MARK: - Source

public struct Stream: Codable, Equatable, Sendable {
    public let file: String
    public let type: String
    public let quality: String

    public init(file: String, type: String, quality: String) {
        self.file = file
        self.type = type
        self.quality = quality
    }

    public init(jsValue: JSValue) {
        self.file = jsValue.forProperty("file")?.toString() ?? ""
        self.type = jsValue.forProperty("type")?.toString() ?? ""
        self.quality = jsValue.forProperty("quality")?.toString() ?? ""
    }
}

// MARK: - VideoLoadingError

public enum VideoLoadingError: Error {
  case invalidURL
  case networkError(Error)
  case dataParsingError(Error)
  case videoNotFound
  case unauthorized
  case other(Error)

  public var localizedDescription: String {
    switch self {
    case .invalidURL:
      "Invalid URL"
    case let .networkError(underlyingError):
      "Network Error: \(underlyingError.localizedDescription)"
    case let .dataParsingError(underlyingError):
      "Data Parsing Error: \(underlyingError.localizedDescription)"
    case .videoNotFound:
      "Video not found"
    case .unauthorized:
      "Unauthorized access"
    case let .other(underlyingError):
      "An error occurred: \(underlyingError.localizedDescription)"
    }
  }
}
