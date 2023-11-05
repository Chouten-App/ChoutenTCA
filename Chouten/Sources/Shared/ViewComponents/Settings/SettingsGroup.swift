//
//  SwiftUIView.swift
//  
//
//  Created by Inumaki on 04.11.23.
//

import SwiftUI

public struct SettingsGroup<Content>: View where Content: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    public init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.indigo)
                
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
                    .regularMaterial
                )
        }
    }
}

#Preview {
    SettingsGroup(title: "SettingsGroup", icon: "gear") {
        Text("Text")
    }
    .padding()
}
