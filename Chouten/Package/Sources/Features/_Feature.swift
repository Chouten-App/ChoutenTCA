//
//  _Feature.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Foundation

protocol Feature: Product, Target {}

extension Feature {
    var path: String? {
        "Sources/Features/\(self.name)"
    }
}
