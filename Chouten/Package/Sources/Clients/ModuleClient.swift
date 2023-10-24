//
//  File.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

struct ModuleClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
        ZIPFoundation()
        Architecture()
    }
}
