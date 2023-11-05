//
//  File.swift
//  
//
//  Created by Inumaki on 04.11.23.
//

struct Appearance: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ViewComponents()
        SharedModels()
        ComposableArchitecture()
    }
}
