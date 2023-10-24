//
//  Discover.swift
//  
//
//  Created by Inumaki on 12.10.23.
//

struct Discover: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ViewComponents()
        Shimmer()
        Search()
        Kingfisher()
        ComposableArchitecture()
        ModuleClient()
    }
}
