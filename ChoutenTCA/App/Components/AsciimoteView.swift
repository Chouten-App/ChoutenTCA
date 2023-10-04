//
//  AsciimoteView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.10.23.
//

import SwiftUI

struct AsciimoteView: View {
    let emote: String
    let description: String?
    
    init(_ emote: String, description: String?) {
        self.emote = emote
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(emote)
                .font(.largeTitle)
                .fontWeight(.bold)
            if let description {
                Text(description)
                    .multilineTextAlignment(.center)
                    .opacity(0.7)
            }
        }
    }
}

#Preview {
    AsciimoteView("(・・ ) ?", description: "Why not try to search for something?")
}
