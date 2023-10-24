//
//  File.swift
//  
//
//  Created by Inumaki on 21.10.23.
//

struct Webview: Feature {
    var dependencies: any Dependencies {
        Architecture()
        ComposableArchitecture()
        ModuleClient()
    }
}
