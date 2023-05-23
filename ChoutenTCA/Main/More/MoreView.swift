//
//  MoreView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 22.05.23.
//

import SwiftUI
import ComposableArchitecture

struct MoreView: View {
    let store: StoreOf<MoreDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("頂点")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Toggle Downloaded Only")
                                .fontWeight(.semibold)
                            Text("Sets the mode of the app to offline")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .opacity(0.7)
                        }
                        
                        Spacer()
                        
                        Toggle(
                            isOn: viewStore.binding(
                                get: \.downloadedOnly,
                                send: MoreDomain.Action.setDownloadedOnly(newValue:)
                            ),
                            label: {})
                        .toggleStyle(M3ToggleStyle())
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Toggle Incognito Mode")
                                .fontWeight(.semibold)
                            Text("For the naughty naughty")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .opacity(0.7)
                        }
                        
                        Spacer()
                        
                        Toggle(isOn: viewStore.binding(
                            get: \.incognito,
                            send: MoreDomain.Action.setIncognito(newValue:)
                        ), label: {})
                            .toggleStyle(M3ToggleStyle())
                    }
                }
                
                Divider()
                    .padding(8)
                
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("Settings")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                
                Divider()
                    .padding(8)
                
                HStack(spacing: 12) {
                    Image("coffee")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .onTapGesture {
                            viewStore.send(.openUrl(url: viewStore.buymeacoffeeString))
                        }
                    
                    Image("ko-fi")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .onTapGesture {
                            viewStore.send(.openUrl(url: viewStore.kofiString))
                        }
                }
                
                Text("Version \(viewStore.versionString)")
                    .font(.caption)
                    .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Color(hex: Colors.Surface.dark)
            }
            .ignoresSafeArea()
        }
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView(
            store: Store(
                initialState: MoreDomain.State(),
                reducer: MoreDomain()
            )
        )
    }
}
