//
//  SourceList.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

struct SourceList: Codable, Equatable, Sendable {
  let title: String
  let list: [SourceData]

  init(title: String, list: [SourceData]) {
    self.title = title
    self.list = list
  }
}
