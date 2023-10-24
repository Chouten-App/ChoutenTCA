//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 10.10.23.
//

import SwiftUI
import ComposableArchitecture

extension MoreFeature.View: View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            NavigationView {
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
