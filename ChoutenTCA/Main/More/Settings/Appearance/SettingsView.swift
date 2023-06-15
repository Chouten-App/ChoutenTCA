//
//  SettingsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI

struct AppearanceView: View {
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                SettingsComponent(
                    title: "Export Theme to JSON",
                    description: "Copy your theme in JSON format",
                    icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    Color(hex: Colors.Primary.dark)
                                )
                                .opacity(0.7)
                                .frame(maxWidth: 14, maxHeight: 18)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    Color(hex: Colors.Primary.dark),
                                    lineWidth: 2
                                )
                                .frame(maxWidth: 14, maxHeight: 18)
                                .offset(x: 4, y: -4)
                        }
                    }
                )
                .onTapGesture {
                    let json = Colors.getAsJson()
                    
                    UIPasteboard.general.setValue(json, forPasteboardType: "public.json")
                }
                
                SettingsComponent(
                    title: "Appearance",
                    description: "Light/Dark/System",
                    icon: {}
                )
                
                SettingsComponent(
                    title: "Theme",
                    description: "Change the Theme of the App",
                    icon: {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 16)
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .foregroundColor(Color(hex: Colors.onSurface.dark))
            .background {
                Color(hex: Colors.Surface.dark)
            }
            .overlay(alignment: .top) {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 18)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    
                    Text("Appearance")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.top, proxy.safeAreaInsets.top)
                .padding(.vertical, 8)
                .frame(maxWidth: proxy.size.width, alignment: .leading)
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .background {
                    //Color(hex: Colors.SurfaceContainer.dark)
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
