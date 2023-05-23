//
//  ChoutenTCAApp.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import SwiftUI
import ComposableArchitecture

@main
struct ChoutenTCAApp: App {
    var body: some Scene {
        WindowGroup {
            Root(
                store: Store(
                    initialState: RootDomain.State(),
                    reducer: RootDomain()
                )
            )
        }
    }
        
}
