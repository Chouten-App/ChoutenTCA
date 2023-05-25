//
//  MoreView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import SwiftUI
import ComposableArchitecture
import CoreHaptics

struct MoreView: View {
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
            VStack {
                Text("頂点")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Toggle Downloaded Only")
                                .fontWeight(.semibold)
                            Text("Sets the mode of the app to offline")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .opacity(0.7)
                        }
                        
                        Spacer()
                        
                        Toggle(
                            isOn: viewStore.binding(
                                get: \.downloadedOnly,
                                send: MoreDomain.Action.setDownloadedOnly(newValue:)
                            ),
                            label: {})
                        .toggleStyle(M3ToggleStyle())
                        .onChange(of: viewStore.downloadedOnly) { value in
                            complexSuccess()
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Toggle Incognito Mode")
                                .fontWeight(.semibold)
                            Text("For the naughty naughty")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .opacity(0.7)
                        }
                        
                        Spacer()
                        
                        Toggle(isOn: viewStore.binding(
                            get: \.incognito,
                            send: MoreDomain.Action.setIncognito(newValue:)
                        ), label: {})
                            .toggleStyle(M3ToggleStyle())
                            .onChange(of: viewStore.incognito) { value in
                                complexSuccess()
                            }
                    }
                }
                
                Divider()
                    .padding(8)
                
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                
                Divider()
                    .padding(8)
                
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
        .onAppear {
            prepareHaptics()
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView(
            store: Store(
                initialState: MoreDomain.State(),
                reducer: MoreDomain()
            )
        )
    }
}
