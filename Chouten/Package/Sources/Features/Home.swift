//
//  File.swift
//  
//
//  Created by Inumaki on 14.12.23.
//

struct Home: Feature {
    var dependencies: any Dependencies {
        Architecture()
        Kingfisher()
        ComposableArchitecture()
        ViewComponents()
        Shimmer()
    }
}
