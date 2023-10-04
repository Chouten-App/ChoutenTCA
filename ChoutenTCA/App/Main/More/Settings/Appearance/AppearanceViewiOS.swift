//
//  SettingsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI
import CoreHaptics
import ComposableArchitecture

struct AppearanceViewiOS: View {
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    @Dependency(\.globalData) var globalData
    @State var colorScheme: CustomColorScheme = .dark
    
    @State var darkTheme: Bool = true
    @State var iosStyle: Bool = true
    @State var amoledMode: Bool = false
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
    
    init() {
        amoledMode = globalData.getAmoledMode()
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
        SettingsPage(title: "Appearance") {
            VStack(alignment: .leading) {
                SettingsGroup(title: "Appearance", icon: "circle.bottomhalf.filled") {
                    HStack {
                        Spacer()
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 80, height: 140)
                            
                            Text("Light")
                            
                            Image(systemName: colorScheme == .light ? "checkmark" : "")
                                .font(.caption2)
                                .frame(width: 12, height: 12)
                                .padding(6)
                                .contentShape(Rectangle())
                                .foregroundColor(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "onPrimary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                         )
                                )
                                .background {
                                    colorScheme == .light ?
                                    AnyView(Circle()
                                        .fill(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "Primary",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
                                        )
                                    )
                                    : AnyView(Circle()
                                        .stroke(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "onSurface",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
                                        )
                                    )
                                }
                                .onTapGesture {
                                    colorScheme = .light
                                    globalData.setColorScheme(.light)
                                }
                        }
                        
                        Spacer()
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 80, height: 140)
                            
                            Text("Dark")
                            
                            Image(systemName: colorScheme == .dark ? "checkmark" : "")
                                .font(.caption2)
                                .frame(width: 12, height: 12)
                                .padding(6)
                                .contentShape(Rectangle())
                                .foregroundColor(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "onPrimary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                         )
                                )
                                .background {
                                    colorScheme == .dark ?
                                    AnyView(Circle()
                                        .fill(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "Primary",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
                                        )
                                    )
                                    : AnyView(Circle()
                                        .stroke(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "onSurface",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
                                        )
                                    )
                                }
                                .onTapGesture {
                                    colorScheme = .dark
                                    globalData.setColorScheme(.dark)
                                }
                        }
                        
                        Spacer()
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 80, height: 140)
                            
                            Text("System")
                            
                            Image(systemName: colorScheme == .system ? "checkmark" : "")
                                .font(.caption2)
                                .frame(width: 12, height: 12)
                                .padding(6)
                                .contentShape(Rectangle())
                                .foregroundColor(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "onPrimary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                         )
                                )
                                .background {
                                    colorScheme == .system ?
                                    AnyView(Circle()
                                        .fill(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "Primary",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
                                        )
                                    )
                                    : AnyView(Circle()
                                        .stroke(
                                            Color(hex:
                                                    Colors.getColor(
                                                        for: "onSurface",
                                                        colorScheme: globalData.getColorScheme()
                                                    )
                                                 )
                                        )
                                    )
                                }
                                .onTapGesture {
                                    colorScheme = .system
                                    globalData.setColorScheme(.system)
                                }
                        }
                        
                        Spacer()
                    }
                }
                
                SettingsGroup(title: "Theme", icon: "sun.max.fill") {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Export Theme to JSON")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
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
                        .onTapGesture {
                            let json = Colors.getAsJson()
                            
                            UIPasteboard.general.setValue(json, forPasteboardType: "public.json")
                        }
                        
                        HStack {
                            Text("iOS Style")
                                .fontWeight(.semibold)
                                .opacity(0.7)
                            
                            Spacer()
                            
                            Toggle(
                                isOn: $iosStyle,
                                label: {}
                            )
                            .tint(
                                Color(hex:
                                        Colors.getColor(
                                            for: "Primary",
                                            colorScheme: globalData.getColorScheme()
                                        )
                                     )
                            )
                            .onChange(of: iosStyle) { value in
                                complexSuccess()
                            }
                        }
                        .disabled(true)
                        
                        if colorScheme == .dark {
                            HStack {
                                Text("AMOLED Mode")
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Toggle(
                                    isOn: $amoledMode,
                                    label: {}
                                )
                                .tint(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "Primary",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                         )
                                )
                                .onChange(of: amoledMode) { value in
                                    globalData.setAmoledMode(value)
                                    if value {
                                        Colors.SurfaceTEMP.dark = Colors.Surface.dark
                                        Colors.Surface.dark = "#000000"
                                    } else {
                                        Colors.Surface.dark = Colors.SurfaceTEMP.dark
                                    }
                                    
                                    complexSuccess()
                                }
                            }
                        }
                        
                        HStack {
                            Text("Theme")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 16)
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.3), value: colorScheme)
        .animation(.spring(response: 0.3), value: amoledMode)
    }
}

struct AppearanceViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceViewiOS()
    }
}
