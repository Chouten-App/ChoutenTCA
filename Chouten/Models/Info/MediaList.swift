//
//  MediaList.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct MediaList: Codable, Equatable, Sendable {
     let title: String
     var pagination: [Pagination]

     init(title: String, pagination: [Pagination]) {
        self.title = title
        self.pagination = pagination
    }
}

extension MediaList {
     init?(jsValue: JSValue) {
        guard
            let title = jsValue["title"]?.toString(),
            let paginationJSValue = jsValue["pagination"]
        else {
            return nil
        }
        let list = paginationJSValue.toArray().compactMap({ element in
            if let jsElement = element as? JSValue {
                return Pagination(jsValue: jsElement)
            } else {
                return nil
            }
        })
        self.init(title: title, pagination: list)
    }
}
