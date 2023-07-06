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

struct SearchView: View {
    let store: StoreOf<SearchDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                VStack {
                    Group {
                        if viewStore.searchResult.isEmpty {
                            VStack {
                                Text("Nothing to show")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.loading {
                            VStack{
                                ActivityIndicatorView(
                                    isVisible: viewStore.binding(
                                        get: \.loading,
                                        send: SearchDomain.Action.setLoading(newLoading:)
                                    ),
                                    type: .growingArc(
                                        Color(hex: Colors.Primary.dark),
                                        lineWidth: 4
                                    )
                                )
                                .frame(width: 50.0, height: 50.0)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<viewStore.searchResult.count) { index in
                                        NavigationLink(
                                            destination: InfoView(
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
                                .padding(.top, 140)
                                .padding(.bottom, 120)
                                .padding(.horizontal, 20)
                                //.navigationTransition(.slide)
                            }
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
                            )
                        )
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .overlay(alignment: .top) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        
                        ZStack(alignment: .leading) {
                            if viewStore.query.isEmpty {
                                Text(viewStore.isDownloadedOnly ? "Search locally..." : "Search for something...")
                                    .opacity(0.7)
                            }
                            
                            TextField("", text: viewStore.binding(
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
                        
                        if !viewStore.query.isEmpty {
                            Image(systemName: "xmark")
                                .font(.footnote)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.resetSearch)
                                }
                        }
                        
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                    }
                    .foregroundColor(Color(hex: Colors.onSurface.dark))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        Color(hex: Colors.SurfaceContainer.dark)
                            .cornerRadius(40)
                    }
                    .padding(20)
                    .padding(.top, viewStore.isDownloadedOnly ? 0 : proxy.safeAreaInsets.top)
                }
                .ignoresSafeArea()
                .onAppear {
                    viewStore.send(.onAppear)
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(
            store: Store(initialState: SearchDomain.State(), reducer: SearchDomain())
        )
    }
}
