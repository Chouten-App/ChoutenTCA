//
//  SettingsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI
import CoreHaptics
import ComposableArchitecture

struct AppearanceView: View {
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    @Dependency(\.globalData) var globalData
    @State var colorScheme: ColorScheme = .dark
    
    @State var darkTheme: Bool = true
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
    
    func complexSuccess() {
        // make sure that the device supports haptics
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()

        // create one intense, sharp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 2)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 2)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)

        // convert those events into a pattern and play it immediately
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Dark Theme")
                            .fontWeight(.semibold)
                        Text(darkTheme ? "On" : "Off")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .opacity(0.7)
                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    Toggle(isOn: $darkTheme, label: {})
                    .toggleStyle(M3ToggleStyle())
                    .onChange(of: darkTheme) { value in
                        complexSuccess()
                        globalData.setColorScheme(darkTheme ? .dark : .light)
                    }
                    .padding(.leading, 12)
                }
                .frame(maxHeight: 40)
                .foregroundColor(
                    Color(hex:
                            Colors.getColor(
                                for: "onSurface",
                                colorScheme: globalData.getColorScheme()
                            )
                         )
                )
                
                SettingsComponent(
                    title: "Export Theme to JSON",
                    description: "Copy your theme in JSON format",
                    icon: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "Primary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                    )
                                )
                                .opacity(0.7)
                                .frame(maxWidth: 14, maxHeight: 18)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "Primary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                    ),
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

struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView()
    }
}
