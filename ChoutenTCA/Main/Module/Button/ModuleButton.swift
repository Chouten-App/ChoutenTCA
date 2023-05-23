//
//  ModuleButton.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI

struct ModuleButton: View {
    @Binding var isShowing: Bool
    @Binding var showButton: Bool
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        Button {
            isShowing = true
        } label: {
            Text("Zoro.to")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 24)
                .frame(minWidth: 80, maxHeight: 56)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            Color(hex: Colors.SecondaryContainer.dark)
                        )
                }
                .shadow(color: Color(hex: Colors.Scrim.dark).opacity(0.08), radius: 2, x: 0, y: 0)
                .shadow(color: Color(hex: Colors.Scrim.dark).opacity(0.16), radius: 24, x: 0, y: 0)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, showButton ? 16 : -140)
        .padding(.bottom, 120)
        .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
        .animation(.spring(response: 0.3), value: showButton)
    }
}

struct ModuleButton_Previews: PreviewProvider {
    static var previews: some View {
        ModuleButton(isShowing: .constant(false), showButton: .constant(true))
    }
}
