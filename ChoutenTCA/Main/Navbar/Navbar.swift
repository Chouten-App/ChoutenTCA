//
//  Navbar.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import SwiftUI
import ComposableArchitecture

struct Navbar: View {
    let store: StoreOf<NavbarDomain>
    @StateObject var Colors = DynamicColors.shared
    @Dependency(\.globalData) var globalData
    
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
                        NavbarItem(label: "History", icon: "clock.arrow.circlepath",selected: viewStore.tab == 2, hasNotification: false)
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
                } else {
                    HStack(spacing: 8) {
                        NavbarItem(label: "Home", icon: "house.fill", selected: viewStore.tab == 0, hasNotification: false)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 0))
                            }
                        NavbarItem(label: "Search", icon: "magnifyingglass",selected: viewStore.tab == 1, hasNotification: false)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 1))
                            }
                        NavbarItem(label: "History", icon: "clock.arrow.circlepath",selected: viewStore.tab == 2, hasNotification: false)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 2))
                            }
                        NavbarItem(label: "More", icon: "ellipsis",selected: viewStore.tab == 3, hasNotification: true)
                            .onTapGesture {
                                viewStore.send(.setTab(newTab: 3))
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 24)
                    .background {
                        Color(hex:
                                Colors.getColor(
                                    for: "SurfaceContainer",
                                    colorScheme: globalData.getColorScheme()
                                )
                        )
                    }
                    
                }
            }
        }
    }
}

struct NavbarItem: View {
    let label: LocalizedStringKey
    let icon: String
    let selected: Bool
    let hasNotification: Bool
    
    @StateObject var Colors = DynamicColors.shared
    @Dependency(\.globalData) var globalData
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Capsule()
                    .fill(
                        Color(hex:
                                Colors.getColor(
                                    for: "SecondaryContainer",
                                    colorScheme: globalData.getColorScheme()
                                )
                        )
                    )
                    .frame(maxWidth: 64, maxHeight: 32)
                    .opacity(selected ? 1.0 : 0.0)
                
                /*
                Circle()
                    .fill(Color("onSecondaryContainer"))
                    .frame(maxWidth: 12, maxHeight: 12)
                 */
                Image(systemName: icon)
                    .frame(maxWidth: 12, maxHeight: 12)
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
            
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(
            Color(hex:
                    Colors.getColor(
                        for: "onSecondaryContainer",
                        colorScheme: globalData.getColorScheme()
                    )
            )
        )
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.width > 600 ? 56 : 80)
    }
}

struct Navbar_Previews: PreviewProvider {
    static var previews: some View {
        Navbar(
            store: Store(
                initialState: NavbarDomain.State(),
                reducer: NavbarDomain()
            )
        )
    }
}
