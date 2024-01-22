//
//  File.swift
//  
//
//  Created by Inumaki on 15.12.23.
//

struct Repo: Feature {
    var dependencies: any Dependencies {
        Architecture()
        Kingfisher()
        ComposableArchitecture()
        ViewComponents()
        Shimmer()
        NukeUI()
        SharedModels()
        ModuleClient()
    }
}
