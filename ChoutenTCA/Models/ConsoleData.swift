//
//  ConsoleData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import Foundation

struct ConsoleData: Codable, Equatable {
    let time: String
    let msg: String
    let type: String
    var moduleName: String
    var moduleIconPath: String
    let lines: String?
}
