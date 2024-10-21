//
//  SourceData.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

struct SourceData: Codable, Hashable, Equatable, Sendable {
  let name: String
  let url: String

  init(name: String, url: String) {
    self.name = name
    self.url = url
  }
}
