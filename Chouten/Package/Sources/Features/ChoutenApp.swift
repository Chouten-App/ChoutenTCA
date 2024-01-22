//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

import Foundation

struct ChoutenApp: Product, Target {
    var name: String {
        "App"
    }

    var path: String? {
        "Sources/Features/\(self.name)"
    }

    var dependencies: any Dependencies {
        Architecture()
        More()
        Player()
        ModuleSheet()
        Discover()
        ViewComponents()
        ComposableArchitecture()
        Shimmer()
        Kingfisher()
        DataClient()
        GRDB()
    }
}
