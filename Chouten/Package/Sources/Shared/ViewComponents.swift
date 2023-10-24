//
//  File.swift
//  
//
//  Created by Inumaki on 12.10.23.
//

import Foundation

struct ViewComponents: Shared {
    var dependencies: any Dependencies {
        Kingfisher()
        SharedModels()
        ComposableArchitecture()
    }
}
