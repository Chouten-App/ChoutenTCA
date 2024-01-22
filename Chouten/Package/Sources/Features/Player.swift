//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

struct Player: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ComposableArchitecture()
        ViewComponents()
        Kingfisher()
        Webview()
        SharedModels()
        ModuleClient()
        DataClient()
        GRDB()
    }
}
