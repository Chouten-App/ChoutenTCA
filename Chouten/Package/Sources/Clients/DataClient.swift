//
//  File.swift
//  
//
//  Created by Inumaki on 29.10.23.
//

struct DataClient: Client {
    var dependencies: any Dependencies {
        ComposableArchitecture()
        Architecture()
    }
}
