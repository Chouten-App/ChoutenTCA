//
//  Video.swift
//
//
//  Created by Inumaki on 29.10.23.
//

import Foundation

// MARK: - ServerData

public struct ServerData: Codable, Equatable, Sendable {
  public let title: String
  public let list: [Server]

  public init(title: String, list: [Server]) {
    self.title = title
    self.list = list
  }
}

// MARK: - Server

public struct Server: Codable, Hashable, Equatable, Sendable {
  public let name: String
  public let url: String

  public init(name: String, url: String) {
    self.name = name
    self.url = url
  }
}

// MARK: - VideoData

public struct VideoData: Codable, Equatable, Sendable {
  public let sources: [Source]
  public let subtitles: [Subtitle]
  public let skips: [SkipTime]
  public let headers: [String: String]?

  public init(sources: [Source], subtitles: [Subtitle], skips: [SkipTime], headers: [String: String]?) {
    self.sources = sources
    self.subtitles = subtitles
    self.skips = skips
    self.headers = headers
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
}

// MARK: - Subtitle

public struct Subtitle: Codable, Equatable, Sendable {
  public let url: String
  public let language: String

  public init(url: String, language: String) {
    self.url = url
    self.language = language
  }
}

// MARK: - Source

public struct Source: Codable, Equatable, Sendable {
  public let file: String
  public let type: String
  public let quality: String

  public init(file: String, type: String, quality: String) {
    self.file = file
    self.type = type
    self.quality = quality
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
