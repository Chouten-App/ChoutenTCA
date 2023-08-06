//
//  ModuleButton.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import SwiftUI
import CoreHaptics
import CoreData
import ComposableArchitecture

// MARK: To be redone, mainly used for testing rn

struct ModuleButtoniOS: View {
    let store: StoreOf<ModuleButtonDomain>
    @Binding var isShowing: Bool
    @Binding var showButton: Bool
    @StateObject var Colors = DynamicColors.shared
    @State private var engine: CHHapticEngine?
    
    @Environment(\.managedObjectContext) var moc
    
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
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
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
            Button {
                isShowing = true
                complexSuccess()
            } label: {
                Text(viewStore.buttonText)
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 24)
                    .frame(minWidth: 80, maxHeight: 56)
                    .background {
                        Capsule()
                            .fill(
                                Color(hex: Colors.SecondaryContainer.dark)
                            )
                    }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 16)
            .padding(.bottom, UIScreen.main.bounds.width > 600 ? 16 : (showButton ? 108 : 24))
            .opacity(showButton ? 1.0 : 0.0)
            .foregroundColor(Color(hex: Colors.onPrimaryContainer.dark))
            .animation(.spring(response: 0.3), value: showButton)
            .onAppear {
                prepareHaptics()
                viewStore.send(.onAppear)
            }
        }
    }
}

struct ModuleButtoniOS_Previews: PreviewProvider {
    static var previews: some View {
        ModuleButtoniOS(
            store: Store(
                initialState: ModuleButtonDomain.State(),
                reducer: ModuleButtonDomain()
            ),
            isShowing: .constant(false),
            showButton: .constant(true)
        )
    }
}
