//
//  ModuleButton.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI

struct ModuleButton: View {
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        Button {
            print("hmmm")
            let data = ["data": FloatyData(
                message: "Floaty is working.",
                error: true,
                action: nil
            )]
            NotificationCenter.default
                .post(
                    name: NSNotification.Name("floaty"),
                    object: nil,
                    userInfo: data
                )
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
        .padding(.trailing, 16)
        .padding(.bottom, 120)
        .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
        .transition(.move(edge: .trailing))
    }
}

struct ModuleButton_Previews: PreviewProvider {
    static var previews: some View {
        ModuleButton()
    }
}
