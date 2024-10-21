//
//  CollectionItem.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation

 struct CollectionItem: Codable, Equatable, Sendable {
     var infoData: InfoData
     var url: String
     var flag: ItemStatus
    
     init(infoData: InfoData, url: String, flag: ItemStatus) {
        self.infoData = infoData
        self.url = url
        self.flag = flag
    }
}
