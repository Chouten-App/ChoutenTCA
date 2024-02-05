//
//  Module.swift
//
//
//  Created by Inumaki on 20.12.23.
//

import Foundation

// MARK: - Module

public struct Module: Hashable, Equatable, Codable, Sendable {
  public let id: String
  public let type: String
  public let subtypes: [String]
  public var icon: String?
  public let name: String
  public let version: String
  public let formatVersion: Int
  public let updateUrl: String
  public let general: GeneralMetadata
  // public var updateStatus: ModuleVersionStatus = .upToDate

  public init(id: String, type: String, subtypes: [String], icon: String? = nil, name: String, version: String, formatVersion: Int, updateUrl: String, general: GeneralMetadata) {
    // , updateStatus: ModuleVersionStatus = .upToDate) {
    self.id = id
    self.type = type
    self.subtypes = subtypes
    self.icon = icon
    self.name = name
    self.version = version
    self.formatVersion = formatVersion
    self.updateUrl = updateUrl
    self.general = general
    // self.updateStatus = updateStatus
  }

  public static let sample = Self(
    id: "whatever",
    type: "source",
    subtypes: ["Anime", "Manga"],
    icon: "https://raw.githubusercontent.com/laynH/Anime-Girls-Holding-Programming-Books/master/C%2B%2B/Sakura_Nene_CPP.jpg",
    name: "Module Name",
    version: "v1.0.0",
    formatVersion: 2,
    updateUrl: "",
    general: GeneralMetadata(
      author: "Chouten",
      description: "This is a description for the module.",
      lang: ["en"],
      baseURL: "",
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
    version: "v1.0.0",
    formatVersion: 2,
    updateUrl: "",
    general: GeneralMetadata(
      author: "Chouten",
      description: "This is a description for the module.",
      lang: ["en"],
      baseURL: "",
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
    version: "v1.0.0",
    formatVersion: 2,
    updateUrl: "",
    general: GeneralMetadata(
      author: "Chouten",
      description: "This is a description for the module.",
      lang: ["en"],
      baseURL: "",
      bgColor: "",
      fgColor: ""
    ) // ,
    // updateStatus: .updateAvailable
  )
}

// MARK: - ModuleVersionStatus

public enum ModuleVersionStatus: Hashable, Equatable, Codable, Sendable {
  case upToDate
  case uninstalled
  case updateAvailable
}

// MARK: - GeneralMetadata

public struct GeneralMetadata: Hashable, Equatable, Codable, Sendable {
  public let author: String
  public let description: String
  public let lang: [String]
  public let baseURL: String
  public let bgColor: String
  public let fgColor: String

  public init(author: String, description: String, lang: [String], baseURL: String, bgColor: String, fgColor: String) {
    self.author = author
    self.description = description
    self.lang = lang
    self.baseURL = baseURL
    self.bgColor = bgColor
    self.fgColor = fgColor
  }
}
