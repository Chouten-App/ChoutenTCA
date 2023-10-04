//
//  SettingsGroup.swift
//  ChoutenTCA
//
//  Created by Inumaki on 21.09.23.
//

import SwiftUI
import ComposableArchitecture

struct SettingsGroup<Content>: View where Content: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    @StateObject var Colors = DynamicColors.shared
    @Dependency(\.globalData) var globalData
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(
                        Color(hex:
                                Colors.getColor(
                                    for: "Primary",
                                    colorScheme: globalData.getColorScheme()
                                )
                             )
                    )
                
                Text(title)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 12)
            
            VStack(spacing: 20) {
                content()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color(hex:
                            Colors.getColor(
                                for: "SurfaceContainer",
                                colorScheme: globalData.getColorScheme()
                            )
                         )
                )
        }
        .foregroundColor(
            Color(hex:
                    Colors.getColor(
                        for: "onSurface",
                        colorScheme: globalData.getColorScheme()
                    )
                 )
        )
    }
}

#Preview {
    SettingsGroup(title: "SettingsGroup", icon: "gear") {
        Text("Text")
    }
    .padding()
}
