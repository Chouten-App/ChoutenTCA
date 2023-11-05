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
                        Navbar(viewStore: viewStore)
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
                        viewStore.send(.setSearchData(SearchData.sampleList))
                    }
                }
            }
        }
    }
}

// navbar
extension SearchFeature.View {
    @MainActor
    func Navbar(viewStore: ViewStore<SearchFeature.State, SearchFeature.Action.ViewAction>) -> some View {
        HStack {
            if !searchbarFocused {
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
                }
                .animation(.easeInOut, value: searchbarFocused)
                .transition(.move(edge: .leading))
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: searchbarFocused ? 12 : 6)
                    .fill(.regularMaterial)
                    .frame(maxWidth: .infinity, minHeight: 32, maxHeight: searchbarFocused ? 32 + 20 + Double(viewStore.queryHistory.count * 32) : 32)
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
                    
                    if searchbarFocused {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("History")
                                .font(.callout)
                                .fontWeight(.bold)
                            
                            ForEach(0..<viewStore.queryHistory.count, id: \.self) { index in
                                let history = viewStore.queryHistory[index]
                                
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
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 5)
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
        .background(
            .regularMaterial
                .opacity(headerOpacity(scrollPosition: viewStore.scrollPosition))
        )
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
        ScrollView(showsIndicators: false) {
            VStack {
                let anim = Animation.linear(duration: 2.0).delay(0.25).repeatForever(autoreverses: false)
                
                LazyVGrid(
                    columns: [
                        .init(alignment: .top),
                        .init(alignment: .top),
                        .init(alignment: .top),
                    ],
                    spacing: 20
                ) {
                    ForEach(0..<9, id: \.self) { index in
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
            /*.background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                print(value)
                viewStore.send(.setScrollPosition(value))
            }
             */
        }
        //.coordinateSpace(name: "scroll")
        .onAppear {
            viewStore.send(
                .setItemOpacity(value: Double(0.0))
            )
        }
        //.transition(.opacity)
    }
}

// Success
extension SearchFeature.View {
    @MainActor
    public func SuccessView(results: [SearchData], viewStore: ViewStore<SearchFeature.State, SearchFeature.Action.ViewAction>, proxy: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                LazyVGrid(
                    columns: [
                        .init(alignment: .top),
                        .init(alignment: .top),
                        .init(alignment: .top),
                    ]
                ) {
                    ForEach(0..<results.count, id: \.self) { index in
                        let result = viewStore.searchResults[index]
                        
                        Button {
                            print("tapped")
                            viewStore.send(.setInfo(result.url), animation: .easeInOut)
                        } label: {
                            VStack {
                                KFImage(
                                    URL(string: result.img)
                                )
                                .fade(duration: 0.6)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
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
                        .contentShape(Rectangle()) // Set the content shape for hit testing
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
