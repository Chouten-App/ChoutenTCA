//
//  HomeSectionChecks.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Foundation

 struct HomeSectionChecks: Codable, Equatable, Hashable {
     let id: String
     let url: String
     var isInCollection: Bool

     init(id: String, url: String, isInCollection: Bool) {
        self.id = id
        self.url = url
        self.isInCollection = isInCollection
    }
}
