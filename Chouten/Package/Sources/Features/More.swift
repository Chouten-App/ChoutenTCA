//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

struct More: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ComposableArchitecture()
    }
}
