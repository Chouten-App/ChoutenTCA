//
//  SettingsPage.swift
//  ChoutenTCA
//
//  Created by Inumaki on 21.09.23.
//

import SwiftUI
import ComposableArchitecture
import CoreHaptics

struct SettingsPage<Content>: View where Content: View {
    let title: String
    let content: () -> Content
    
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    @Dependency(\.globalData) var globalData
    
    @State private var engine: CHHapticEngine?
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                content()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 120)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .foregroundColor(
                Color(hex:
                        Colors.getColor(
                            for: "onSurface",
                            colorScheme: globalData.getColorScheme()
                        )
                     )
            )
            .background {
                Color(hex:
                        Colors.getColor(
                            for: "Surface",
                            colorScheme: globalData.getColorScheme()
                        )
                )
            }
            .overlay(alignment: .top) {
                HStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .offset(x: -1)
                        .padding(6)
                        .contentShape(Rectangle())
                        .foregroundColor(Color(hex: Colors.onPrimary.dark))
                        .background {
                            Circle()
                                .fill(
                                    Color(hex: Colors.Primary.dark)
                                )
                        }
                        .onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(maxWidth: 20)
                }
                .padding(.horizontal, 12)
                .padding(.top, proxy.safeAreaInsets.top)
                .padding(.vertical, 8)
                .frame(maxWidth: proxy.size.width, alignment: .leading)
                .foregroundColor(
                    Color(hex:
                            Colors.getColor(
                                for: "onSurface",
                                colorScheme: globalData.getColorScheme()
                            )
                         )
                )
                .background {
                    //Color(hex: Colors.SurfaceContainer.dark)
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                prepareHaptics()
            }
        }
    }
}

#Preview {
    SettingsPage(title: "Settings") {
        Text("TEXT")
    }
}
