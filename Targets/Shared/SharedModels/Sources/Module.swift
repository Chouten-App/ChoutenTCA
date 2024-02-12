//
//  Module.swift
//
//
//  Created by Inumaki on 20.12.23.
//

import Foundation
@preconcurrency
import Semver
import Tagged

// MARK: - Module

public struct Module: Hashable, Equatable, Codable, Sendable, Identifiable {
  public typealias FormatVersion = Tagged<(Self, formatVersion: ()), Int>
  public typealias Version = Tagged<(Self, version: ()), Semver>

  public let id: Tagged<Self, String>
  // TODO: Make this type enum specific?
  public let type: String
  // TODO: Make this type enum specific
  public let subtypes: [String]
  // TODO: Decide if icon should be a URL-specific variable
  public var icon: String?
  public let name: String
  public let version: Version
  public let formatVersion: FormatVersion
  public let updateUrl: URL
  public let metadata: Metadata

  public init(
    id: ID,
    type: String,
    subtypes: [String],
    icon: String? = nil,
    name: String,
    version: Version,
    formatVersion: FormatVersion,
    updateUrl: URL,
    metadata: Metadata
  ) {
    self.id = id
    self.type = type
    self.subtypes = subtypes
    self.icon = icon
    self.name = name
    self.version = version
    self.formatVersion = formatVersion
    self.updateUrl = updateUrl
    self.metadata = metadata
  }
}

// MARK: Module + VersionStatus

extension Module {
  public enum VersionStatus: Hashable, Equatable, Codable, Sendable {
    case upToDate
    case uninstalled
    case updateAvailable
  }
}

// MARK: Module + Metadata

extension Module {
  public struct Metadata: Hashable, Equatable, Codable, Sendable {
    public let author: String
    // TODO: make description optional and change name to avoid clashing with `CustomStringConvertible`
    public let description: String
    // TODO: Make lang a enum type strict language
    public let lang: [String]
    public let baseURL: URL
    // TODO: Make this optional and specific hex-string
    public let bgColor: String
    // TODO: <ake this optional and specific hex-string
    public let fgColor: String

    public init(
      author: String,
      description: String,
      lang: [String],
      baseURL: URL,
      bgColor: String,
      fgColor: String
    ) {
      self.author = author
      self.description = description
      self.lang = lang
      self.baseURL = baseURL
      self.bgColor = bgColor
      self.fgColor = fgColor
    }
  }
}

extension Module {
  public static let sample = Self(
    id: "whatever",
    type: "source",
    subtypes: ["Anime", "Manga"],
    icon: "https://raw.githubusercontent.com/laynH/Anime-Girls-Holding-Programming-Books/master/C%2B%2B/Sakura_Nene_CPP.jpg",
    name: "Module Name",
    version: .init(.init(1, 0, 0)),
    formatVersion: 2,
    updateUrl: .init(string: "/").unsafelyUnwrapped,
    metadata: Metadata(
      author: "Chouten",
      description: "This is a description for the module.",
      lang: ["en"],
      baseURL: .init(string: "/").unsafelyUnwrapped,
      bgColor: "",
      fgColor: ""
    )
  )

  public static let sample2 = Self(
    id: "whatever2",
    type: "source",
    subtypes: ["Anime", "Manga"],
    icon: "https://raw.githubusercontent.com/laynH/Anime-Girls-Holding-Programming-Books/master/C%2B%2B/Sakura_Nene_CPP.jpg",
    name: "Module Name",
    version: .init(.init(1, 0, 0)),
    formatVersion: 2,
    updateUrl: .init(string: "/").unsafelyUnwrapped,
    metadata: Metadata(
      author: "Chouten",
      description: "This is a description for the module.",
      lang: ["en"],
      baseURL: .init(string: "/").unsafelyUnwrapped,
      bgColor: "",
      fgColor: ""
    )
  )

  public static let sampleUpdate = Self(
    id: "whatever3",
    type: "source",
    subtypes: ["Comics"],
    icon: "https://raw.githubusercontent.com/laynH/Anime-Girls-Holding-Programming-Books/master/C%2B%2B/Sakura_Nene_CPP.jpg",
    name: "Module Name (Update)",
    version: .init(.init(1, 0, 0)),
    formatVersion: 2,
    updateUrl: .init(string: "/").unsafelyUnwrapped,
    metadata: Metadata(
      author: "Chouten",
      description: "This is a description for the module.",
      lang: ["en"],
      baseURL: .init(string: "/").unsafelyUnwrapped,
      bgColor: "",
      fgColor: ""
    )
  )
}
