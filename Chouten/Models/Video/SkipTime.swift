//
//  SkipTime.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

struct SkipTime: Codable, Equatable, Sendable {
    let start: Double
    let end: Double
    let type: String

    init(start: Double, end: Double, type: String) {
        self.start = start
        self.end = end
        self.type = type
    }

    init(jsValue: JSValue) {
        self.start = jsValue["start"]?.toDouble() ?? 0.0
        self.end = jsValue["end"]?.toDouble() ?? 0.0
        self.type = jsValue["type"]?.toString() ?? ""
    }
}
