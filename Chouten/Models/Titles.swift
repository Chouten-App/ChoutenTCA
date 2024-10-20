//
//  Titles.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

struct Titles: Codable, Equatable, Sendable, Hashable {
    let primary: String
    let secondary: String?

    init(primary: String, secondary: String?) {
        self.primary = primary
        self.secondary = secondary
    }
    
    init?(jsValue: JSValue) {
        guard
            let primary = jsValue["primary"]?.toString()
        else {
            return nil
        }

        let secondary = jsValue["secondary"]?.toString()

        self.init(primary: primary, secondary: secondary)
    }
}
