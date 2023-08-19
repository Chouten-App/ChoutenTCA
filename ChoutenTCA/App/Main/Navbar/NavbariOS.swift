//
//  NavbariOS.swift
//  ChoutenTCA
//
//  Created by Inumaki on 27.07.23.
//

import SwiftUI
import ComposableArchitecture

struct NavbariOS: View {
    let store: StoreOf<NavbarDomain>
    @StateObject var Colors = DynamicColors.shared
    @Dependency(\.globalData) var globalData
    @Namespace var animation
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Group {
                if viewStore.screenWidth > 600 {
                    VStack(spacing: 8) {
                        NavbarItem(label: "Home", icon: "house.fill", selected: viewStore.tab == 0, hasNotification: false)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 0))
                            }
                        NavbarItem(label: "Search", icon: "magnifyingglass",selected: viewStore.tab == 1, hasNotification: false)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 1))
                            }
                        NavbarItem(label: "Repo", icon: "clock.arrow.circlepath",selected: viewStore.tab == 2, hasNotification: false)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 2))
                            }
                        NavbarItem(label: "More", icon: "ellipsis",selected: viewStore.tab == 3, hasNotification: true)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 3))
                            }
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: 80, maxHeight: .infinity)
                    .background {
                        Color(hex:
                                Colors.getColor(
                                    for: "SurfaceContainer",
                                    colorScheme: globalData.getColorScheme()
                                )
                        )
                    }
                }
                else {
                    HStack(alignment: .top, spacing: 8) {
                        NavbarItemiOS(label: "Home", icon: "house.fill", selected: viewStore.tab == 0, hasNotification: false, animation: animation)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 0), animation: .spring(response: 0.3))
                            }
                        NavbarItemiOS(label: "Search", icon: "magnifyingglass",selected: viewStore.tab == 1, hasNotification: false, animation: animation)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 1), animation: .spring(response: 0.3))
                            }
                        NavbarItemiOS(label: "Repo", icon: "shippingbox.fill",selected: viewStore.tab == 2, hasNotification: false, animation: animation)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 2), animation: .spring(response: 0.3))
                            }
                        NavbarItemiOS(label: "More", icon: "ellipsis",selected: viewStore.tab == 3, hasNotification: true, animation: animation)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 3), animation: .spring(response: 0.3))
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 24)
                    .background(.ultraThinMaterial)
                }
            }
        }
    }
}

struct NavbarItemiOS: View {
    let label: LocalizedStringKey
    let icon: String
    let selected: Bool
    let hasNotification: Bool
    let animation: Namespace.ID
    
    @StateObject var Colors = DynamicColors.shared
    @Dependency(\.globalData) var globalData
    
    var body: some View {
        VStack(spacing: 4) {
            if selected {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 20, height: 4)
                    .padding(.bottom, 8)
                    .foregroundColor(
                        Color(hex:
                                Colors.getColor(
                                    for: "Primary",
                                    colorScheme: globalData.getColorScheme()
                                )
                             )
                    )
                    .matchedGeometryEffect(id: "indicator", in: animation)
            } else {
                Spacer()
                    .frame(maxHeight: 12)
            }
            
            VStack(spacing: 4) {
                ZStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .contentShape(Rectangle())
                    
                    Text("3")
                        .foregroundColor(
                            Color(hex:
                                    Colors.getColor(
                                        for: "onError",
                                        colorScheme: globalData.getColorScheme()
                                    )
                                 )
                        )
                        .font(.caption2)
                        .padding(4)
                        .background {
                            Circle()
                                .fill(
                                    Color(hex:
                                            Colors.getColor(
                                                for: "Error",
                                                colorScheme: globalData.getColorScheme()
                                            )
                                         )
                                )
                        }
                        .offset(x: 6, y: -6)
                        .opacity(hasNotification ? 1.0 : 0.0)
                }
                .frame(width: 24, height: 24)
                
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .background {
                Circle()
                    .frame(minWidth: 200)
                    .blur(radius: 8)
                    .opacity(selected ? 0.2 : 0.0)
            }
        }
        .foregroundColor(
            Color(hex:
                    Colors.getColor(
                        for: selected ? "Primary" : "onSurface",
                        colorScheme: globalData.getColorScheme()
                    )
            )
        )
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.width > 600 ? 56 : 64, alignment: .top)
    }
}

struct NavbariOS_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack {
                ForEach(0..<15) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundColor(
                            Color(
                                hex: DynamicColors().SecondaryContainer.dark
                            )
                        )
                        .frame(width: 200, height: 120)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(alignment: .bottom) {
            NavbariOS(
                store: Store(
                    initialState: NavbarDomain.State(),
                    reducer: NavbarDomain()
                )
            )
            .frame(maxWidth: .infinity)
        }
        .background {
            Color(
                hex: DynamicColors().Surface.dark
            )
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}
