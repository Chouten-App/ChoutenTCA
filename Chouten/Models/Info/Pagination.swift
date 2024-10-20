//
//  Pagination.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct Pagination: Codable, Equatable, Sendable {
     let id: String
     let title: String?
     let items: [MediaItem]

     init(id: String, title: String?, items: [MediaItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
}

extension Pagination {
     init?(jsValue: JSValue) {
        guard
            let id = jsValue["id"]?.toString(),
            let title = jsValue["title"]?.toString(),
            let itemsJSValue = jsValue["items"]
        else {
            return nil
        }
        let list = itemsJSValue.toArray().compactMap({ element in
            if let jsElement = element as? JSValue {
                return MediaItem(jsValue: jsElement)
            } else {
                return nil
            }
        })
        self.init(id: id, title: title, items: list)
    }
}
