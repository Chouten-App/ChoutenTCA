//
//  SearchResultInfo.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct SearchResultInfo: Codable, Equatable, Hashable {
     var count: Int?
     var pages: Int
     var next: String?

     init(count: Int? = nil, pages: Int, next: String? = nil) {
        self.count = count
        self.pages = pages
        self.next = next
    }

     init?(jsValue: JSValue) {
        guard let pages = jsValue["pages"]?.toInt32() else {
            return nil
        }

        let convertedPages = Int(pages)

        let count = jsValue["count"]?.toInt32() as? Int
        let next = jsValue["next"]?.toString()


        self.init(count: count, pages: convertedPages, next: next)
    }
}
