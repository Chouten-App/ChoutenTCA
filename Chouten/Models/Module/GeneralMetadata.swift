//
//  GeneralMetadata.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Foundation

 struct GeneralMetadata: Hashable, Equatable, Codable, Sendable {
     let author: String
     let description: String
     let lang: [String]
     let baseURL: String
     let bgColor: String
     let fgColor: String

     init(author: String, description: String, lang: [String], baseURL: String, bgColor: String, fgColor: String) {
        self.author = author
        self.description = description
        self.lang = lang
        self.baseURL = baseURL
        self.bgColor = bgColor
        self.fgColor = fgColor
    }
}
