//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

import Foundation

protocol Shared: Product, Target {}

extension Shared {
    var path: String? {
        "Sources/Shared/\(self.name)"
    }
}
