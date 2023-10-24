//
//  File.swift
//  
//
//  Created by Inumaki on 19.10.23.
//

struct ModuleSheet: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ModuleClient()
        ComposableArchitecture()
        Kingfisher()
    }
}
