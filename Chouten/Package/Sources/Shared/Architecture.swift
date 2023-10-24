//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

struct Architecture: Shared {
    var dependencies: any Dependencies {
        FoundationHelpers()
        ComposableArchitecture()
    }
}
