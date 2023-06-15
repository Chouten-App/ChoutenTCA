//
//  SettingsComponent.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI

struct SettingsComponent<Content: View>: View {
    let title: String
    let description: String
    @ViewBuilder var icon: Content
    
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .opacity(0.7)
            }
            
            Spacer()
            
            icon
        }
        .foregroundColor(Color(hex: Colors.onSurface.dark))
    }
}

struct SettingsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsComponent(title: "Title", description: "Description", icon: {
            
        })
    }
}
