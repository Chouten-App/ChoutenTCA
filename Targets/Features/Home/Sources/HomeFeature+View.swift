//
//  SwiftUIView.swift
//  
//
//  Created by Inumaki on 14.12.23.
//

import Architecture
import SwiftUI
import ComposableArchitecture

extension HomeFeature.View {
    @MainActor
    public var body: some View {
        VStack {
            Text("Coming Soon!")
        }
    }
}

#Preview {
    HomeFeature.View(
        store: .init(
            initialState: .init(),
            reducer: { HomeFeature() }
        )
    )
}
