//
//  AppearanceFeature+View.swift
//
//
//  Created by Inumaki on 04.11.23.
//

// swiftlint:disable identifier_name

import Architecture
import SwiftUI
import ViewComponents

extension AppearanceFeature.View {
  @MainActor public var body: some View {
    WithPerceptionTracking {
      SettingsPage("Appearance") {
        SettingsGroup(title: "Appearance", icon: "circle.bottomhalf.filled") {
          HStack {
            Spacer()

            ColorSchemeDisplay("Light", selected: store.colorScheme == 0) {
              RoundedRectangle(cornerRadius: 6)
                .fill(.white)
                .frame(width: 80, height: 140)
            }
            .onTapGesture {
              send(.setColorScheme(to: .light))
            }

            Spacer()

            ColorSchemeDisplay("Dark", selected: store.colorScheme == 1) {
              RoundedRectangle(cornerRadius: 6)
                .fill(.black)
                .frame(width: 80, height: 140)
            }
            .onTapGesture {
              send(.setColorScheme(to: .dark))
            }

            Spacer()

            ColorSchemeDisplay("System", selected: store.colorScheme == 2) {
              RoundedRectangle(cornerRadius: 6)
                .fill(
                  LinearGradient(
                    stops: [
                      .init(
                        color: .white,
                        location: 0.0
                      ),
                      .init(
                        color: .white,
                        location: 0.5
                      ),
                      .init(
                        color: .black,
                        location: 0.5
                      ),
                      .init(
                        color: .black,
                        location: 1.0
                      )
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
                .frame(width: 80, height: 140)
            }
            .onTapGesture {
              send(.setColorScheme(to: .system))
            }

            Spacer()
          }
        }

        SettingsGroup(title: "Theme", icon: "sun.max.fill") {
          VStack(spacing: 20) {
            HStack {
              Text("Theme")
                .fontWeight(.semibold)

              Spacer()

              Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 16)
            }

            HStack {
              Text("Ambient Mode")

              Spacer()

              Toggle("", isOn: $store.ambientMode)
                .tint(.indigo)
            }

            HStack {
              Text("Dynamic Info Background")

              Spacer()

              Toggle("", isOn: $store.dynamicInfo)
                .tint(.indigo)
                .fixedSize()
            }
          }
        }
      }
    }
  }
}

extension AppearanceFeature.View {
  @MainActor
  func ColorSchemeDisplay(
    _ scheme: String,
    selected: Bool,
    @ViewBuilder content: @escaping () -> some View
  ) -> some View {
    VStack {
      content()

      Text(scheme)

      Image(systemName: selected ? "checkmark" : "")
        .font(.caption2)
        .frame(width: 12, height: 12)
        .padding(6)
        .contentShape(Rectangle())
        .foregroundColor(.indigo)
        .background {
          selected ?
            AnyView(
              Circle()
                .fill(.regularMaterial)
            )
            : AnyView(
              Circle()
                .stroke(.regularMaterial, lineWidth: 1.0)
            )
        }
    }
  }
}

#Preview("Appearance") {
  AppearanceFeature.View(
    store: .init(
      initialState: .init(),
      reducer: { AppearanceFeature() }
    )
  )
}
