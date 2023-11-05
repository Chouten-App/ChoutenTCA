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
import Kingfisher

extension AppFeature.View: View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Group {
                        switch viewStore.state.selected {
                        case .home:
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Good Evening")
                                            .opacity(0.7)
                                        Text("Inumaki")
                                            .font(.largeTitle)
                                            .fontWeight(.bold)
                                    }
                                    
                                    Spacer()
                                    
                                    KFImage(URL(string: "https://i.pinimg.com/736x/fc/b9/8a/fcb98aba272d7c1d4c24984f77614031.jpg"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 64, height: 64)
                                        .clipShape(Circle())
                                }
                                .padding(.vertical, 30)
                                .padding(.horizontal)
                                
                                // Continue Watching
                                VStack(alignment: .leading) {
                                    Text("Continue Watching")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(0..<4, id: \.self) { _ in
                                                VStack(alignment: .leading) {
                                                    KFImage(URL(string: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg"))
                                                        .resizable()
                                                        .aspectRatio(16/9, contentMode: .fill)
                                                        .frame(width: 260)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                        .overlay(alignment: .topTrailing) {
                                                            Text("1")
                                                                .font(.title3)
                                                                .fontWeight(.bold)
                                                                .padding(.horizontal)
                                                                .padding(.vertical, 4)
                                                                .background {
                                                                    Capsule()
                                                                        .fill(.indigo)
                                                                }
                                                                .padding()
                                                        }
                                                    
                                                    Text("Title")
                                                        .font(.title3)
                                                        .padding(.horizontal, 12)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // List
                                VStack(alignment: .leading) {
                                    HStack(alignment: .bottom) {
                                        Text("Planned To Watch")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Text("See more")
                                            .font(.caption)
                                            .opacity(0.7)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .opacity(0.7)
                                    }
                                    .padding(.horizontal)
                                    .padding(.top)
                                    
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(0..<24, id: \.self) { index in
                                                VStack {
                                                    KFImage(
                                                        URL(string: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg")
                                                    )
                                                    .fade(duration: 0.8)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 90, height: 130)
                                                    .cornerRadius(12)
                                                    
                                                    VStack(alignment: .leading) {
                                                        Text("Title")
                                                            .font(.subheadline)
                                                            .frame(width: 72, alignment: .leading)
                                                        
                                                        Text("- / -")
                                                            .font(.caption)
                                                            .frame(width: 72, alignment: .leading)
                                                            .opacity(0.7)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        case .discover:
                            DiscoverFeature.View(
                                store: store.scope(
                                    state: \.discover,
                                    action: Action.InternalAction.discover
                                )
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .overlay(alignment: .bottom) {
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
                    .allowsHitTesting(viewStore.showTabbar)
                }
                .overlay {
                    if viewStore.videoUrl != nil {
                        PlayerFeature.View(
                            store: store.scope(
                                state: \.player,
                                action: Action.InternalAction.player
                            )
                        )
                        .opacity(viewStore.showPlayer ? 1.0 : 0.0)
                    }
                }
                .onAppear {
                    viewStore.send(.view(.onAppear))
                }
            }
            .supportedOrientation(viewStore.fullscreen ? .landscape : .portrait)
            .prefersHomeIndicatorAutoHidden(viewStore.fullscreen)
            .preferredColorScheme(
                colorScheme == 0 ? .light :
                    colorScheme == 1 ? .dark :
                        .none
            )
            .animation(.easeInOut, value: colorScheme)
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
