//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

struct Info: Feature {
    var dependencies: any Dependencies {
        Architecture()
        Kingfisher()
        ComposableArchitecture()
        ViewComponents()
        Webview()
        DataClient()
    }
}
