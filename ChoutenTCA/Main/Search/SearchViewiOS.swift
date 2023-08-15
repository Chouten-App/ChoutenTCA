//
//  SearchView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import NavigationTransitions
import ActivityIndicatorView

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct SearchViewiOS: View {
    let store: StoreOf<SearchDomain>
    @StateObject var Colors = DynamicColors.shared
    
    // TEMP
    @State private var scrollPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                VStack {
                    Group {
                        if viewStore.loadingStatus == .loading {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<16, id: \.self) { index in
                                        VStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .frame(width: 110, height: 160)
                                                .redacted(reason: .placeholder)
                                                .shimmer(
                                                    delay: 0.2 * Double(index)
                                                )
                                            
                                            RoundedRectangle(cornerRadius: 6)
                                                .frame(width: 110, height: 16)
                                                .redacted(reason: .placeholder)
                                                .shimmer(
                                                    delay: 0.1 + ( 0.2 * Double(index) )
                                                )
                                            
                                            HStack {
                                                Spacer()
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .frame(width: 40, height: 12)
                                                    .redacted(reason: .placeholder)
                                                    .shimmer(
                                                        delay: 0.2 + ( 0.2 * Double(index) )
                                                    )
                                            }
                                            .frame(width: 110)
                                        }
                                        .frame(maxWidth: 110)
                                    }
                                }
                                .padding(.top, 190)
                                .padding(.bottom, 120)
                                .padding(.horizontal, 20)
                                .background(
                                    GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                                    }
                                )
                                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                    print(value)
                                    withAnimation(.spring(response: 0.3)) {
                                        scrollPosition = value
                                    }
                                }
                            }
                            .coordinateSpace(name: "scroll")
                        } else if viewStore.loadingStatus == .success {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<viewStore.searchResult.count, id: \.self) { index in
                                        NavigationLink(
                                            destination: InfoViewiOS(
                                                url: viewStore.searchResult[index].url,
                                                store: self.store.scope(
                                                    state: \.infoState,
                                                    action: SearchDomain.Action.info
                                                )
                                            )
                                        ) {
                                            VStack {
                                                if viewStore.searchResult[index].img.contains("https://") {
                                                    KFImage(URL(string: viewStore.searchResult[index].img))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 160)
                                                        .cornerRadius(12)
                                                } else {
                                                    Image(viewStore.searchResult[index].img)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 110, height: 180)
                                                        .frame(minWidth: 110, minHeight: 160)
                                                        .cornerRadius(12)
                                                }
                                                
                                                Text(viewStore.searchResult[index].title)
                                                    .frame(width: 110)
                                                    .lineLimit(1)
                                                
                                                HStack {
                                                    Spacer()
                                                    
                                                    Text("\(viewStore.searchResult[index].currentCount != nil ? String(viewStore.searchResult[index].currentCount!) : "⁓") / \(viewStore.searchResult[index].totalCount != nil ? String(viewStore.searchResult[index].totalCount!) : "⁓")")
                                                        .font(.caption)
                                                }
                                                .frame(width: 110)
                                            }
                                            .frame(maxWidth: 110)
                                        }
                                        .simultaneousGesture(
                                            TapGesture()
                                                .onEnded{ value in
                                                    print(viewStore.searchResult[index].url)
                                                    viewStore.send(.resetInfoData)
                                                }
                                        )
                                    }
                                }
                                .padding(.top, 190)
                                .padding(.bottom, 120)
                                .padding(.horizontal, 20)
                                .background(
                                    GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                                    }
                                )
                                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                    print(value)
                                    withAnimation(.spring(response: 0.3)) {
                                        scrollPosition = value
                                    }
                                }
                            }
                            .coordinateSpace(name: "scroll")
                        } else {
                            VStack {
                                Text("Nothing to show")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(hex: Colors.Surface.dark))
                .background {
                    if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                        WebView(
                            viewStore: ViewStore(
                                self.store.scope(
                                    state: \.webviewState,
                                    action: SearchDomain.Action.webview
                                )
                            ),
                            payload: viewStore.query
                        ) { result in
                            print(result)
                            viewStore.send(.parseResult(data: result))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .overlay(alignment: .top) {
                    VStack {
                        if scrollPosition.y > -50 {
                            HStack {
                                Text("Search")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                /*
                                KFImage(URL(string: ""))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .cornerRadius(64)
                                 */
                            }
                            .foregroundColor(Color(hex: Colors.onSurface.dark))
                        }
                        
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                
                                ZStack(alignment: .leading) {
                                    if viewStore.query.isEmpty {
                                        Text(viewStore.isDownloadedOnly ? "Search locally..." : "Search for something...")
                                            .opacity(0.7)
                                    }
                                    
                                    TextField(
                                        "",
                                        text: viewStore.binding(
                                            get: \.query,
                                            send: SearchDomain.Action.setQuery(query:)
                                        )
                                    )
                                    .disableAutocorrection(true)
                                    .onSubmit {
                                        if viewStore.isDownloadedOnly {
                                            
                                        } else {
                                            viewStore.send(.resetWebview)
                                        }
                                    }
                                }
                            }
                            .foregroundColor(Color(hex: Colors.onSurface.dark))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background {
                                Color(hex: Colors.SurfaceContainer.dark)
                                    .cornerRadius(10)
                            }
                            
                            if !viewStore.query.isEmpty {
                                Text("Cancel")
                                    .foregroundColor(Color(hex: Colors.onSurface.dark))
                            }
                        }
                        .padding(.top, scrollPosition.y > -50 ? 0 : -12)
                    }
                    .padding(20)
                    .padding(.top, viewStore.isDownloadedOnly ? 0 : proxy.safeAreaInsets.top)
                    .background {
                        Color(hex: Colors.Surface.dark)
                    }
                    .animation(.spring(response: 0.3), value: viewStore.query)
                }
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct SearchViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        SearchViewiOS(
            store: Store(initialState: SearchDomain.State(), reducer: SearchDomain())
        )
    }
}
