//
//  Title.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation

struct Title: Codable, Equatable {
    let english: String?
    let native: String?
    let romaji: String
    let userPreferred: String?
}
