//
//  ItemStatus.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//


import Foundation

 enum ItemStatus: String, Codable {
    case inprogress = "In-Progress"
    case completed = "Completed"
    case planned = "Planned"
    case dropped = "Dropped"
    case none = "None"
}
