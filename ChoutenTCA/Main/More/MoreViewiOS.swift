//
//  MoreViewiOS.swift
//  ChoutenTCA
//
//  Created by Inumaki on 27.07.23.
//

import SwiftUI
import CoreHaptics
import ComposableArchitecture
import Kingfisher

struct MoreViewiOS: View {
    let store: StoreOf<MoreDomain>
    @StateObject var Colors = DynamicColors.shared
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
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack(spacing: 12) {
                    Text("頂点")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 20)
                    
                    VStack {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .frame(width: 20, height: 20)
                                .padding(4)
                                .foregroundColor(Color(hex: Colors.onPrimary.dark))
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            Color(hex: Colors.Primary.dark)
                                        )
                                }
                            
                            Text("Downloaded Only")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle(
                                isOn: viewStore.binding(
                                    get: \.downloadedOnly,
                                    send: MoreDomain.Action.setDownloadedOnly(newValue:)
                                ),
                                label: {})
                            .tint(Color(hex: Colors.Primary.dark))
                            .onChange(of: viewStore.downloadedOnly) { value in
                                complexSuccess()
                            }
                        }
                        
                        HStack {
                            Image(systemName: "eyeglasses")
                                .frame(width: 16, height: 16)
                                .padding(6)
                                .foregroundColor(Color(hex: Colors.onTertiary.dark))
                                .background {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            Color(hex: Colors.Tertiary.dark)
                                        )
                                }
                            
                            Text("Incognito Mode")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle(isOn: viewStore.binding(
                                get: \.incognito,
                                send: MoreDomain.Action.setIncognito(newValue:)
                            ), label: {})
                            .tint(Color(hex: Colors.Primary.dark))
                            .onChange(of: viewStore.incognito) { value in
                                complexSuccess()
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
                    
                    VStack {
                        NavigationLink(
                            destination: AppearanceViewiOS()
                        ) {
                            HStack {
                                Image(systemName: "swatchpalette.fill")
                                    .frame(width: 20, height: 20)
                                    .padding(4)
                                    .foregroundColor(Color(hex: Colors.onPrimary.dark))
                                    .background {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                Color(hex: Colors.Primary.dark)
                                            )
                                    }
                                
                                Text("Appearance")
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 16)
                            }
                        }
                        
                        NavigationLink(
                            destination: NetworkView()
                        ) {
                            HStack {
                                Image(systemName: "wifi")
                                    .frame(width: 20, height: 20)
                                    .padding(4)
                                    .foregroundColor(Color(hex: Colors.onTertiary.dark))
                                    .background {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                Color(hex: Colors.Tertiary.dark)
                                            )
                                    }
                                
                                Text("Network")
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 16)
                            }
                        }
                        
                        NavigationLink(
                            destination: DeveloperView()
                        ) {
                            HStack {
                                Image(systemName: "laptopcomputer")
                                    .frame(width: 20, height: 20)
                                    .padding(4)
                                    .foregroundColor(Color(hex: Colors.onSecondary.dark))
                                    .background {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                Color(hex: Colors.Secondary.dark)
                                            )
                                    }
                                
                                Text("Developer")
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
                    
                    HStack(spacing: 12) {
                        Image("coffee")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 200)
                            .cornerRadius(8)
                            .onTapGesture {
                                viewStore.send(.openUrl(url: viewStore.buymeacoffeeString))
                            }
                        
                        Image("ko-fi")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 200)
                            .cornerRadius(8)
                            .onTapGesture {
                                viewStore.send(.openUrl(url: viewStore.kofiString))
                            }
                    }
                    
                    Text("Version \(viewStore.versionString)")
                        .font(.caption)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background {
                    Color(hex: Colors.Surface.dark)
                }
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
        .onAppear {
            prepareHaptics()
        }
    }
}

struct MoreViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        MoreViewiOS(
            store: Store(
                initialState: MoreDomain.State(),
                reducer: MoreDomain()
            )
        )
    }
}
