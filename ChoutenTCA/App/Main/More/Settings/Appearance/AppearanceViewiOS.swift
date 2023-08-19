//
//  SettingsView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.06.23.
//

import SwiftUI
import CoreHaptics
import ComposableArchitecture

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        // 1
        Button(action: {
            
            // 2
            configuration.isOn.toggle()
            
        }, label: {
            Image(systemName: configuration.isOn ? "checkmark" : "")
                .font(.caption2)
                .frame(width: 12, height: 12)
                .padding(6)
                .foregroundColor(Color(hex: DynamicColors().onPrimary.dark))
                .background {
                    configuration.isOn ?
                    AnyView(Circle()
                        .fill(Color(hex: DynamicColors().Primary.dark)))
                    : AnyView(Circle()
                        .stroke(Color(hex: DynamicColors().onSurface.dark)))
                }
        })
    }
}

struct AppearanceViewiOS: View {
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode
    @Dependency(\.globalData) var globalData
    @State var colorScheme: ColorScheme = .dark
    
    @State var darkTheme: Bool = true
    @State var iosStyle: Bool = true
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
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "circle.bottomhalf.filled")
                            .foregroundColor(Color(hex: Colors.Primary.dark))
                        
                        Text("Appearance")
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 12)
                    
                    HStack {
                        
                        Spacer()
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 80, height: 140)
                            
                            Text("Light")
                            
                            Toggle(isOn: .constant(false), label: {})
                                .toggleStyle(iOSCheckboxToggleStyle())
                        }
                        
                        Spacer()
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 80, height: 140)
                            
                            Text("Dark")
                            
                            Toggle(isOn: .constant(true), label: {})
                                .toggleStyle(iOSCheckboxToggleStyle())
                        }
                        
                        Spacer()
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: 80, height: 140)
                            
                            Text("System")
                            
                            Toggle(isOn: .constant(false), label: {})
                                .toggleStyle(iOSCheckboxToggleStyle())
                        }
                        
                        Spacer()
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            Color(hex: Colors.SurfaceContainer.dark)
                        )
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(Color(hex: Colors.Primary.dark))
                        
                        Text("Theme")
                            .fontWeight(.bold)
                    }
                    .padding(.bottom, 12)
                    
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
                            
                            Spacer()
                            
                            Toggle(
                                isOn: $iosStyle,
                                label: {}
                            )
                            .tint(Color(hex: Colors.Primary.dark))
                            .onChange(of: iosStyle) { value in
                                complexSuccess()
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
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            Color(hex: Colors.SurfaceContainer.dark)
                        )
                }
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
                        .frame(width: 16, height: 16)
                        .offset(x: -1)
                        .padding(4)
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
                    
                    Text("Appearance")
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

struct AppearanceViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceViewiOS()
    }
}
