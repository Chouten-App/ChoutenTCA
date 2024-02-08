//
//  chouten.swift
//
//
//  Created by Inumaki on 24.12.23.
//

import Foundation
import GRDB
import SwiftUI

// MARK: - Media

public struct Media: Codable, Equatable, FetchableRecord, PersistableRecord, Sendable {
  public var id: String = UUID().uuidString

  public var moduleID: String
  public var image: String
  public var current: Double
  public var duration: Double
  public var title: String
  public var description: String?
  public var mediaUrl: String
  public var number: Double

  public init(moduleID: String, image: String, current: Double, duration: Double, title: String, description: String? = nil, mediaUrl: String, number: Double) {
    self.moduleID = moduleID
    self.image = image
    self.current = current
    self.duration = duration
    self.title = title
    self.description = description
    self.mediaUrl = mediaUrl
    self.number = number
  }
}

// MARK: - FLAGS

public enum FLAGS: String, Codable, Equatable, CaseIterable, Sendable {
  case none // 0
  case planned // 1
  case finished // 2
  case current // 3
  case dropped // 4
  case again // 5
  case paused // 6

  public var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

// MARK: - Collection

public struct Collection: Codable, Equatable {
  public var id: String = UUID().uuidString

  public var items: [CollectionItem]
  public var name: String
  public init(items: [CollectionItem], name: String) {
    self.items = items
    self.name = name
  }

  public static let sample = Self(
    items: [
      CollectionItem(
        flag: .current,
        moduleID: "",
        url: "",
        title: "Title",
        image: InfoData.img,
        currentCount: 8,
        totalCount: 12
      ),
      CollectionItem(
        flag: .current,
        moduleID: "",
        url: "",
        title: "Title 2",
        image: InfoData.img,
        currentCount: 1,
        totalCount: 12
      ),
      CollectionItem(
        flag: .finished,
        moduleID: "",
        url: "",
        title: "Title 3",
        image: InfoData.img,
        currentCount: 12,
        totalCount: 12
      ),
      CollectionItem(
        flag: .current,
        moduleID: "",
        url: "",
        title: "Title 4",
        image: InfoData.img,
        currentCount: 15,
        totalCount: 24
      )
    ],
    name: "Anime"
  )
}

extension Collection {
  var itemsJSON: String {
    get {
      let encoder = JSONEncoder()
      guard let jsonData = try? encoder.encode(items) else { return "[]" }
      return String(data: jsonData, encoding: .utf8) ?? "[]"
    }
    set {
      let decoder = JSONDecoder()
      guard let jsonData = newValue.data(using: .utf8),
            let decodedItems = try? decoder.decode([CollectionItem].self, from: jsonData) else {
        items = []
        return
      }
      items = decodedItems
    }
  }
}

// MARK: - CollectionItem

public struct CollectionItem: Codable, Equatable, FetchableRecord, PersistableRecord {
  public var flag: FLAGS = .none

  public var moduleID: String

  public var url: String
  public var title: String
  public var image: String
  public var currentCount: Int?
  public var totalCount: Int?
  public var indicatorText: String?
}
