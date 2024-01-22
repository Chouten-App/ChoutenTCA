//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import SwiftUI
import ComposableArchitecture
import Appearance
import NukeUI

extension MoreFeature.View: View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            VStack(spacing: 12) {
                Text("頂点")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                
                VStack {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                            .frame(width: 20, height: 20)
                            .padding(4)
                            .background(.blue)
                            .cornerRadius(6)
                        
                        Text("Downloaded Only")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        
                        Toggle(
                            isOn: viewStore.$isDownloadedOnly,
                            label: {}
                        )
                    }
                    
                    HStack {
                        Image(systemName: "eyeglasses")
                            .frame(width: 16, height: 16)
                            .padding(6)
                            .background(.red)
                            .cornerRadius(6)
                        
                        Text("Incognito Mode")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Toggle(isOn: viewStore.$isIncognito, label: {})
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            .regularMaterial
                        )
                }
                
                VStack {
                    Button {
                        viewStore.send(.setPageState(to: .appearance), animation: .easeInOut)
                    } label: {
                        HStack {
                            Image(systemName: "swatchpalette.fill")
                                .frame(width: 20, height: 20)
                                .padding(4)
                                .background(.pink)
                                .cornerRadius(6)
                            
                            Text("Appearance")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 16)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "wifi")
                            .frame(width: 20, height: 20)
                            .padding(4)
                            .background(.yellow)
                            .cornerRadius(6)
                        
                        Text("Network")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 16)
                    }
                    
                    Button {
                        viewStore.send(.setPageState(to: .developer), animation: .easeInOut)
                    } label: {
                        HStack {
                            Image(systemName: "laptopcomputer")
                                .frame(width: 20, height: 20)
                                .padding(4)
                                .background(.indigo)
                                .cornerRadius(6)
                            
                            Text("Developer")
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 16)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            .regularMaterial
                        )
                }
                
                Text("Version \(viewStore.versionString)")
                    .font(.caption)
                    .padding(.top, 12)
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .overlay {
                if viewStore.pageState == .appearance {
                    AppearanceFeature.View(
                        store: self.store.scope(
                            state: \.appearance,
                            action: Action.InternalAction.appearance
                        )
                    )
                    .transition(.move(edge: .trailing))
                } else if viewStore.pageState == .developer {
                    // Logs
                    VStack {
                        ScrollView {
                            VStack {
                                ForEach(0..<4, id: \.self) { index in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            LazyImage(
                                                url: URL(string: "https://pbs.twimg.com/profile_images/1676239730994737152/Ii75RYHN_400x400.jpg"),
                                                transaction: .init(animation: .easeInOut(duration: 0.4))
                                            ) { state in
                                                if let image = state.image {
                                                  image
                                                    .resizable()
                                                } else {
                                                    Color.gray.opacity(0.3)
                                                }
                                            }
                                            .scaledToFill()
                                            .frame(maxWidth: 32, maxHeight: 32)
                                            .cornerRadius(6)
                                            
                                            HStack {
                                                Text("Log")
                                                    .fontWeight(.bold)
                                                Text("(index.ts | 14:23)")
                                                    .font(.footnote)
                                            }
                                            .opacity(0.7)
                                            
                                            Spacer()
                                            
                                            Text("14:56:236")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .opacity(0.7)
                                        }
                                        
                                        Text(verbatim: "https://aniwatch.to/ajax/v2/episode/sources?id=609965")
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .background(.regularMaterial)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .padding(.top, 40)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.background)
                    .overlay(alignment: .top) {
                        HStack(spacing: 20) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .offset(x: -1)
                                .padding(6)
                                .contentShape(Rectangle())
                                .foregroundColor(.primary)
                                .background {
                                    Circle()
                                        .fill(
                                            .regularMaterial
                                        )
                                }
                            
                            Text("Logs")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                        //.background(.regularMaterial)
                    }
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}

#Preview("More") {
    MoreFeature.View(
        store: .init(
            initialState: .init(versionString: "x.x.x"),
            reducer: { MoreFeature() }
        )
    )
}
