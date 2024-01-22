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
import ASCollectionView
import NukeUI

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
                ZStack {
                    LoadableView(loadable: viewStore.searchLoadable) { results in
                        SuccessView(
                            results: results,
                            viewStore: viewStore,
                            proxy: proxy
                        )
                    } failedView: { error in
                        ErrorView()
                    } loadingView: {
                        LoadingView(viewStore: viewStore, proxy: proxy)
                    } pendingView: {
                        NotStartedView(viewStore: viewStore, proxy: proxy)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
                    .background {
                        if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                            WebviewFeature.View(
                                store: self.store.scope(
                                    state: \.webviewState,
                                    action: Action.InternalAction.webview
                                ),
                                payload: "{\"query\": \"\(viewStore.query)\", \"page\": \(viewStore.page)}"
                            ) { result in
                                viewStore.send(.parseResult(data: result))
                            }
                            .hidden()
                            .frame(maxWidth: 0, maxHeight: 0)
                        }
                    }
                    .overlay(alignment: .top) {
                        Navbar(viewStore: viewStore, proxy: proxy)
                    }
                    
                    if viewStore.infoVisible {
                        InfoFeature.View(
                            store: self.store.scope(
                                state: \.info,
                                action: Action.InternalAction.info
                            ),
                            isVisible: viewStore.binding(
                                get: \.infoVisible,
                                send: { .setInfoVisible($0) }
                            ),
                            dragState: viewStore.binding(
                                get: \.dragState,
                                send: { .setDragState($0) }
                            )
                        )
                        .transition(.move(edge: .trailing))
                    }
                }
                .onAppear {
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                        //viewStore.send(.setLoadable(.loading))
                        viewStore.send(.setSearchData(SearchData.sampleList))
                    }
                }
                .onChange(of: searchbarFocused) { newValue in
                    viewStore.send(.setSearchFocused(newValue))
                }
            }
        }
    }
}

// navbar
extension SearchFeature.View {
    @MainActor
    func Navbar(viewStore: ViewStore<SearchFeature.State, SearchFeature.Action.ViewAction>, proxy: GeometryProxy) -> some View {
        HStack {
            if !viewStore.searchFocused {
                NavigationBackButton {
                    viewStore.send(.backButtonPressed, animation: .easeInOut)
                }
                .animation(.easeInOut, value: viewStore.searchFocused)
                .transition(.move(edge: .leading))
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: viewStore.searchFocused ? 12 : 6)
                    .fill(.regularMaterial)
                    .frame(maxWidth: .infinity, maxHeight: 32)
                    .matchedGeometryEffect(id: "searchBG", in: animation)
                
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .matchedGeometryEffect(id: "searchIcon", in: animation)
                        
                        TextField("Search for something", text: viewStore.$query) {
                            viewStore.send(.search)
                        }
                        .tint(.indigo)
                        .focused($searchbarFocused)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 5)
            }
            .animation(.easeInOut, value: viewStore.searchFocused)
        }
        .clipped()
        .padding(.bottom)
        .padding(.horizontal)
        .background(
            .regularMaterial
                .opacity(viewStore.headerOpacity)
        )
        /*.overlay(alignment: .bottom) {
            if searchbarFocused {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<viewStore.queryHistory.count, id: \.self) { index in
                        let history = viewStore.queryHistory[index]
                        
                        VStack {
                            HStack {
                                Text(history)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                    .opacity(0.7)
                                
                                Spacer()
                                
                                Button {
                                    viewStore.send(.removeQuery(at: index), animation: .easeInOut)
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            if index != viewStore.queryHistory.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(12)
                .background(.regularMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
                .offset(y: proxy.safeAreaInsets.top + 12)
                .animation(.easeInOut, value: viewStore.searchFocused)
                .transition(.scale(scale: 1.0, anchor: .top))
            }
        }*/
        .animation(.easeInOut, value: viewStore.searchFocused)
    }
}

// Not Started
extension SearchFeature.View {
    @MainActor
    public func NotStartedView(viewStore: ViewStore<SearchFeature.State, SearchFeature.Action.ViewAction>, proxy: GeometryProxy) -> some View {
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
    }
}

// Loading
extension SearchFeature.View {
    @MainActor
    public func LoadingView(viewStore: ViewStore<SearchFeature.State, SearchFeature.Action.ViewAction>, proxy: GeometryProxy) -> some View {
        VStack {
            let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)
            
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 110, height: 160)
                                .shimmering(
                                    active: true,
                                    animation: anim.delay(0.2 * Double(index))
                                )
                                .opacity(0.3)
                            
                            VStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: 110, height: 160)
                                    .shimmering(
                                        active: true,
                                        animation: anim.delay(0.1 + ( 0.2 * Double(index) ))
                                    )
                                    .frame(width: 110, height: 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .opacity(0.2)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(width: 110, height: 160)
                                    .shimmering(
                                        active: true,
                                        animation: anim.delay(0.2 + ( 0.2 * Double(index) ))
                                    )
                                    .frame(width: 40, height: 12)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .opacity(0.3)
                            }
                        }
                        .opacity(viewStore.itemOpacity)
                        .animation(.easeInOut(duration: 2.0).repeatForever().delay(0.2 * Double(index)), value: viewStore.itemOpacity)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, proxy.safeAreaInsets.top)
        .onAppear {
            viewStore.send(
                .setItemOpacity(value: Double(0.0))
            )
        }
    }
}

// Success
extension SearchFeature.View {
    @MainActor
    public func SuccessView(results: [SearchData], viewStore: ViewStore<SearchFeature.State, SearchFeature.Action.ViewAction>, proxy: GeometryProxy) -> some View {
        ASCollectionView(data: results, dataID: \.self)
        { result, _ in
            Button {
                viewStore.send(.setInfo(result.url), animation: .easeInOut)
            } label: {
                VStack {
                    LazyImage(
                        url: URL(string: result.img),
                        transaction: .init(animation: .easeInOut(duration: 0.4))
                    ) { state in
                        if let image = state.image {
                          image
                            .resizable()
                        } else {
                            let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .frame(width: 110, height: 160)
                                .shimmering(
                                    active: true,
                                    animation: anim
                                )
                                .opacity(0.3)
                        }
                    }
                    .scaledToFill()
                    .frame(width: 110, height: 160)
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .font(.subheadline)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(width: 94, alignment: .leading)
                        
                        Text("\(result.currentCountString)/\(result.totalCountString)")
                            .font(.caption)
                            .frame(width: 94, alignment: .leading)
                            .opacity(0.7)
                    }
                    .foregroundColor(.white)
                }
            }
            .contentShape(Rectangle())
            .frame(width: 110)
        }
        .layout {
            .grid(
                layoutMode: .adaptive(withMinItemSize: 120),
                itemSpacing: 8,
                lineSpacing: 12,
                itemSize: .estimated(110),
                sectionInsets: .init(top: 50, leading: 12, bottom: 0, trailing: 12)
            )
        }
        .onReachedBoundary { boundary in
            if boundary == .bottom && !viewStore.isFetching {
                print("Load next results")
                // Run search logic with page count + 1
                viewStore.send(.increasePageNumber)
                viewStore.send(.search)
            }
        }
        .onScroll { contentOffset, _ in
            if 50 + contentOffset.y > 90 {
                if viewStore.headerOpacity < 1.0 {
                    viewStore.send(.setHeaderOpacity(1.0))
                }
            } else {
                viewStore.send(.setHeaderOpacity((50.0 + contentOffset.y) / CGFloat(90)))
            }
        }
        .ignoresSafeArea()
    }
}

// Error
extension SearchFeature.View {
    @MainActor
    public func ErrorView() -> some View {
        VStack(spacing: 24) {
            Text("(×﹏×)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Nothing was found with that query. Please try a different search term.")
                .opacity(0.7)
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
