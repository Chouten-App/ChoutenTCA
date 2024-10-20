//
//  SeasonData.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct SeasonData: Codable, Equatable, Sendable {
     let name: String
     let url: String
     var selected: Bool?

     init(name: String, url: String, selected: Bool? = nil) {
        self.name = name
        self.url = url
        self.selected = selected
    }
}

extension SeasonData {
     init?(jsValue: JSValue) {
        guard
            let name = jsValue["name"]?.toString(),
            let url = jsValue["url"]?.toString()
        else {
            return nil
        }

        let selected = jsValue["selected"]?.toBool()

        self.init(name: name, url: url, selected: selected)
    }
}
