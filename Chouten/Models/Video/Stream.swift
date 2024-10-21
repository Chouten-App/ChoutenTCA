//
//  Stream.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

struct Stream: Codable, Equatable, Sendable {
    let file: String
    let type: String
    let quality: String

    init(file: String, type: String, quality: String) {
        self.file = file
        self.type = type
        self.quality = quality
    }

    init(jsValue: JSValue) {
        self.file = jsValue.forProperty("file")?.toString() ?? ""
        self.type = jsValue.forProperty("type")?.toString() ?? ""
        self.quality = jsValue.forProperty("quality")?.toString() ?? ""
    }
}
