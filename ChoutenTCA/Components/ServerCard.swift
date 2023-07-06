//
//  ServerCard.swift
//  ChoutenTCA
//
//  Created by Inumaki on 20.06.23.
//

import SwiftUI

struct ServerCard: View {
    let title: String
    let selected: Bool
    
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text("MULTI QUALITY")
                    .font(.caption)
            }
            
            Spacer()
            
            Image(systemName: "arrow.down.to.line.compact")
                .font(.system(size: 24))
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    Color(hex:
                            !selected ?
                          (Colors.OutlineVariant.dark) :
                            (Colors.Secondary.dark)
                          )
                )
        }
        .foregroundColor(
            Color(hex:
                    !selected ?
                  (Colors.onSurface.dark) :
                    (Colors.onSecondary.dark)
                 )
        )
    }
}

struct ServerCard_Previews: PreviewProvider {
    static var previews: some View {
        ServerCard(
            title: "Vidstreaming",
            selected: true
        )
    }
}
