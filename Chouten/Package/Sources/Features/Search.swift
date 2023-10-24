//
//  File.swift
//  
//
//  Created by Inumaki on 14.10.23.
//

struct Search: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ViewComponents()
        Shimmer()
        Info()
        Kingfisher()
        ComposableArchitecture()
        SharedModels()
        ModuleClient()
        Webview()
    }
}
