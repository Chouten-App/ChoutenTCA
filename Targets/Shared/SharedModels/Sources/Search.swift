//
//  Search.swift
//
//
//  Created by Inumaki on 17.10.23.
//

import Foundation

// MARK: - SearchData

public struct SearchData: Codable, Hashable, Equatable {
  public let url: String
  public let img: String
  public let title: String
  public let indicatorText: String?
  public let currentCount: Int?
  public let totalCount: Int?

  public init(url: String, img: String, title: String, indicatorText: String?, currentCount: Int?, totalCount: Int?) {
    self.url = url
    self.img = img
    self.title = title
    self.indicatorText = indicatorText
    self.currentCount = currentCount
    self.totalCount = totalCount
  }

  public var currentCountString: String {
    if let currentCount {
      "\(currentCount)"
    } else {
      "⁓"
    }
  }

  public var totalCountString: String {
    if let totalCount {
      "\(totalCount)"
    } else {
      "⁓"
    }
  }

  public static let sample = Self(
    url: "",
    img: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
    title: "Title",
    indicatorText: "18+",
    currentCount: 12,
    totalCount: 12
  )

  public static let sampleList = [Self](repeating: sample, count: 50)
}

// MARK: Identifiable

extension SearchData: Identifiable {
  public var id: String {
    "\(hashValue)"
  }
}
