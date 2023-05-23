//
//  M3ToggleStyle.swift
//  ModularSaikouS
//
//  Created by Inumaki on 04.05.23.
//

import SwiftUI

struct M3ToggleStyle: ToggleStyle {
    @StateObject var Colors = DynamicColors.shared
    
    func makeBody(configuration: Self.Configuration) -> some View {
 
        return HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(configuration.isOn ?
                          Color(hex: Colors.Primary.dark) :
                            Color(hex: Colors.SurfaceContainer.dark)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(configuration.isOn ?
                                  Color(hex: Colors.Outline.dark).opacity(0.0) :
                                    Color(hex: Colors.Outline.dark)
                                    , lineWidth: 2)
                    }
                    .frame(maxWidth: 52, minHeight: 32, maxHeight: 32)
                    .animation(.spring(response: 0.3), value: configuration.isOn)
                
                Circle()
                    .fill(
                        configuration.isOn ?
                        Color(hex: Colors.onPrimary.dark) :
                            Color(hex: Colors.Outline.dark)
                    )
                    .frame(maxWidth: configuration.isOn ? 24 : 16, maxHeight: configuration.isOn ? 24 : 16)
                    
                    .offset(x: configuration.isOn ? 8 :  -8)
                    .animation(.spring(response: 0.3), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
            
            configuration.label
                .font(.system(size: 16, weight: .bold))
                .padding(.leading, 8)
                .foregroundColor(
                    Color(hex: Colors.onSurface.dark)
                )
        }
 
    }
}

struct M3ToggleStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            Toggle("Subbed", isOn: .constant(false))
                .toggleStyle(M3ToggleStyle())
            Toggle("Dubbed", isOn: .constant(true))
                .toggleStyle(M3ToggleStyle())
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background {
            Color(hex: "#121316")
        }
        .ignoresSafeArea()
    }
}
