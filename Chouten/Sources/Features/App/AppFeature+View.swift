//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import Architecture
import SwiftUI
import More
import Discover
import ViewComponents
import Player
import ModuleSheet

extension AppFeature.View: View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    ZStack {
                        switch viewStore.state.selected {
                        case .home:
                            VStack {
                                Text("HOME")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .discover:
                            DiscoverFeature.View(
                                store: store.scope(
                                    state: \.discover,
                                    action: Action.InternalAction.discover
                                )
                            )
                        case .repos:
                            VStack {
                                Text("REPOS")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        case .more:
                            MoreFeature.View(
                                store: store.scope(
                                    state: \.more,
                                    action: Action.InternalAction.more
                                )
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .safeAreaInset(edge: .bottom) {
                    VStack(spacing: 0) {
                        ModuleSheetFeature.View(
                            store: store.scope(
                                state: \.sheet,
                                action: Action.InternalAction.sheet
                            )
                        )
                        NavBar(viewStore.selected)
                    }
                    .offset(y: viewStore.showTabbar ? 0 :  proxy.safeAreaInsets.bottom + 120)
                }
                .overlay {
                    PlayerFeature.View(
                        store: store.scope(
                            state: \.player,
                            action: Action.InternalAction.player
                        )
                    )
                    .opacity(viewStore.showPlayer ? 1.0 : 0.0)
                    .allowsHitTesting(viewStore.showPlayer)
                }
                .onAppear {
                    viewStore.send(.view(.onAppear))
                }
            }
        }
    }
}

private struct NavBarItem: View {
    let tab: AppFeature.State.Tab
    var selected: Bool
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack(spacing: 4) {
            if selected {
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: 20, height: 4)
                    .padding(.bottom, 8)
                    .foregroundColor(
                        .indigo
                    )
                    .matchedGeometryEffect(id: "indicator", in: animation)
            } else {
                Spacer()
                    .frame(height: 12)
            }
                
            VStack(spacing: 4) {
                Image(systemName: selected ? tab.selected : tab.image)
                    .font(.system(size: 18, weight: .bold))
                    .contentShape(Rectangle())
                    .frame(width: 24, height: 24)
                
                Text(tab.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .background {
                if selected {
                    Circle()
                        .fill(.indigo)
                        .frame(minWidth: 200)
                        .blur(radius: 20)
                        .scaleEffect(1.5)
                        .opacity(0.2)
                        .matchedGeometryEffect(id: "indicatorBG", in: animation)
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: 64, alignment: .top)
        .animation(.spring(response: 0.2), value: selected)
    }
}

extension AppFeature.View {
    @MainActor
    func NavBar(_ selected: Self.State.Tab) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(State.Tab.allCases, id: \.rawValue) { tab in
                NavBarItem(tab: tab, selected: tab == selected, animation: animation)
                    .onTapGesture {
                        store.send(.view(.changeTab(tab)))
                    }
            }
        }
        .background(.regularMaterial)
        .background(.regularMaterial)
    }
}

#Preview("App") {
    AppFeature.View(
        store: .init(
            initialState: .init(),
            reducer: { AppFeature() }
        )
    )
}
