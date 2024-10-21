//
//  Subtitle.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

struct Subtitle: Codable, Equatable, Sendable {
    let url: String
    let language: String

    init(url: String, language: String) {
        self.url = url
        self.language = language
    }

    init(jsValue: JSValue) {
        self.url = jsValue["url"]?.toString() ?? ""
        self.language = jsValue["language"]?.toString() ?? ""
    }
}
