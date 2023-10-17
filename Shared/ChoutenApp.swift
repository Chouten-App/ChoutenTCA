//
//  ChoutenAppApp.swift
//  ChoutenApp
//
//  Created by Inumaki on 11.10.23.
//

import SwiftUI
import App
import Player

@main
struct ChoutenAppApp: App {
    var body: some Scene {
        WindowGroup {
            AppFeature.View(
                store: .init(
                    initialState: .init(
                        versionString: "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "x.x")(\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "x"))"
                    ),
                    reducer: { AppFeature() }
                )
            )
        }
    }
}
