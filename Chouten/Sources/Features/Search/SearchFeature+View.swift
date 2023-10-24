//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 14.10.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import Shimmer
import SharedModels
import ViewComponents
import Webview
import Info

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}


extension SearchFeature.View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy in
                Group {
                    switch viewStore.state.state {
                    case .notStarted:
                        VStack(spacing: 24) {
                            Text("(         ) ?")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Why not try to search for something?")
                                .opacity(0.7)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay {
                            HStack(spacing: 28) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white)
                                    .frame(width: 6, height: 6)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.white)
                                    .frame(width: 6, height: 6)
                            }
                            .offset(x: -17, y: -20)
                        }
                        .ignoresSafeArea()
                        .transition(.opacity)
                    case .loading:
                        ScrollView(showsIndicators: false) {
                            VStack {
                                let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<16, id: \.self) { index in
                                        VStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .frame(width: 110, height: 160)
                                                .shimmering(
                                                    active: true,
                                                    animation: anim.delay(0.2 * Double(index))
                                                )
                                            
                                            VStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .frame(width: 110, height: 160)
                                                    .shimmering(
                                                        active: true,
                                                        animation: anim.delay(0.1 + ( 0.2 * Double(index) ))
                                                    )
                                                    .frame(width: 110, height: 16)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .frame(width: 110, height: 160)
                                                    .shimmering(
                                                        active: true,
                                                        animation: anim.delay(0.2 + ( 0.2 * Double(index) ))
                                                    )
                                                    .frame(width: 40, height: 12)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                            }
                                        }
                                        .opacity(viewStore.itemOpacity)
                                        .animation(.easeInOut(duration: 3.0).repeatForever().delay(0.2 * Double(index)), value: viewStore.itemOpacity)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, proxy.safeAreaInsets.top)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                                }
                            )
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                print(value)
                                viewStore.send(.setScrollPosition(value))
                            }
                        }
                        .coordinateSpace(name: "scroll")
                        .onAppear {
                            viewStore.send(.setItemOpacity(value: Double(0.0)))
                        }
                        .transition(.opacity)
                    case .success:
                        ScrollView(showsIndicators: false) {
                            VStack {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<viewStore.searchResults.count, id: \.self) { index in
                                        let result = viewStore.searchResults[index]
                                        Button {
                                            viewStore.send(.setInfo(result.url))
                                        } label: {
                                            VStack {
                                                KFImage(
                                                    URL(string: result.img)
                                                )
                                                .onSuccess { _ in
                                                    withAnimation(.easeIn(duration: 0.4)) {
                                                        // Add any animation effect you want here
                                                    }
                                                }
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 110, height: 160)
                                                .cornerRadius(12)
                                                
                                                VStack(alignment: .leading) {
                                                    Text(result.title)
                                                        .font(.subheadline)
                                                        .lineLimit(2)
                                                        .frame(width: 94, alignment: .leading)
                                                    
                                                    Text("\(result.currentCountString)/\(result.totalCountString)")
                                                        .font(.caption)
                                                        .frame(width: 94, alignment: .leading)
                                                        .opacity(0.7)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, proxy.safeAreaInsets.top)
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scrollSuccess")).origin)
                                }
                            )
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                print(value)
                                viewStore.send(.setScrollPosition(value))
                            }
                        }
                        .coordinateSpace(name: "scrollSuccess")
                        .transition(.opacity)
                    case .error:
                        VStack(spacing: 24) {
                            Text("(×﹏×)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Nothing was found with that query. Please try a different search term.")
                                .opacity(0.7)
                        }
                    }
                    
                }
                .background(.black)
                .background {
                    if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                        WebviewFeature.View(
                            store: self.store.scope(
                                state: \.webviewState,
                                action: Action.InternalAction.webview
                            ),
                            payload: viewStore.query
                        ) { result in
                            //print(result)
                            viewStore.send(.parseResult(data: result))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .overlay(alignment: .top) {
                    HStack {
                        Button {
                            viewStore.send(.backButtonPressed, animation: .easeInOut)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(8)
                                .background {
                                    Circle()
                                        .fill(.regularMaterial)
                                }
                                .transition(.move(edge: .leading))
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.regularMaterial)
                                .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32)
                                .matchedGeometryEffect(id: "searchBG", in: animation)
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .matchedGeometryEffect(id: "searchIcon", in: animation)
                                
                                TextField("Search for something", text: viewStore.$query) {
                                    viewStore.send(.search)
                                }
                                .tint(.indigo)
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding(.top, proxy.safeAreaInsets.top)
                    .padding(.bottom)
                    .padding(.horizontal)
                    .background(
                        .regularMaterial
                            .opacity(headerOpacity(scrollPosition: viewStore.scrollPosition))
                    )
                    .frame(maxHeight: proxy.safeAreaInsets.top + 48)
                    .clipped()
                    .ignoresSafeArea()
                }
                .overlay {
                    if let infoUrl = viewStore.infoUrl {
                        InfoFeature.View(
                            store: .init(
                                initialState: .init(
                                    url: infoUrl
                                ),
                                reducer: { InfoFeature() }
                            )
                        )
                    }
                }
            }
        }
    }
}

#Preview("Search") {
    SearchFeature.View(
        store: .init(
            initialState: .init(),
            reducer: { SearchFeature() }
        ),
        animation: Namespace().wrappedValue
    )
}
