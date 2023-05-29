//
//  SearchView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct SearchView: View {
    let store: StoreOf<SearchDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                VStack {
                    Group {
                        if viewStore.results.isEmpty {
                            VStack {
                                Text("Nothing to show")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(viewStore.results) { result in
                                        VStack {
                                            if result.image.contains("https://") {
                                                KFImage(URL(string: result.image))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 160)
                                                    .cornerRadius(12)
                                            } else {
                                                Image(result.image)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 110, height: 180)
                                                    .frame(minWidth: 110, minHeight: 160)
                                                    .cornerRadius(12)
                                            }
                                            
                                            Text(result.title.english ?? result.title.romaji)
                                                .frame(width: 110)
                                                .lineLimit(1)
                                            
                                            HStack {
                                                Spacer()
                                                
                                                Text("\(result.currentEpisodeCount != nil ? String(result.currentEpisodeCount!) : "⁓") / \(result.totalEpisodes != nil ? String(result.totalEpisodes!) : "⁓")")
                                                    .font(.caption)
                                            }
                                            .frame(width: 110)
                                        }
                                        .frame(maxWidth: 110)
                                    }
                                }
                                .padding(.top, 140)
                                .padding(.bottom, 120)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color(hex: Colors.Surface.dark))
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
                                    viewStore.send(.search)
                                }
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
