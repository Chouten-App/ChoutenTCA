//
//  InfoView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 01.06.23.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct InfoView: View {
    let url: String
    let store: StoreOf<InfoDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                ScrollView {
                    if viewStore.infoData != nil {
                        VStack {
                            Header(viewStore: viewStore, proxy: proxy)
                            ExtraInfo(viewStore: viewStore)
                        }
                    }
                }
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .background {
                    Color(hex: Colors.Surface.dark)
                }
                .background {
                    if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                        WebView(
                            viewStore: ViewStore(
                                self.store.scope(
                                    state: \.webviewState,
                                    action: InfoDomain.Action.webview
                                )
                            )
                        )
                    }
                }
                .ignoresSafeArea()
            }
            .onAppear {
                print(url)
                viewStore.send(.onAppear(url: url))
            }
        }
    }
    
    @ViewBuilder
    func Header(viewStore: ViewStoreOf<InfoDomain>, proxy: GeometryProxy) -> some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            GeometryReader {reader in
                FillAspectImage(
                    url: URL(string: viewStore.infoData!.banner ?? viewStore.infoData!.poster),
                    doesAnimateHorizontal: false
                )
                .blur(radius: viewStore.infoData!.banner != nil ? 0.0 : 6.0)
                .overlay {
                    LinearGradient(stops: [
                        Gradient.Stop(color: Color(hex: Colors.Surface.dark).opacity(0.9), location: 0.0),
                        Gradient.Stop(color: Color(hex: Colors.Surface.dark).opacity(0.4), location: 1.0),
                    ], startPoint: .bottom, endPoint: .top)
                }
                .frame(
                    width: reader.size.width,
                    height: reader.size.height + (reader.frame(in: .global).minY > 0 ? reader.frame(in: .global).minY : 0),
                    alignment: .top
                )
                .contentShape(Rectangle())
                .clipped()
                .offset(y: reader.frame(in: .global).minY <= 0 ? 0 : -reader.frame(in: .global).minY)
                
            }
            .frame(height: 280)
            .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
            
            // Info
            HStack(alignment: .bottom) {
                KFImage(URL(string: viewStore.infoData!.poster))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 120, maxHeight: 180)
                    .cornerRadius(12)
                
                VStack(alignment: .leading) {
                    Text(viewStore.infoData!.titles.secondary ?? "")
                        .font(.caption)
                        .fontWeight(.heavy)
                        .opacity(0.7)
                    Text(viewStore.infoData!.titles.primary)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(3)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewStore.infoData!.status ?? "")
                            .foregroundColor(Color(hex:Colors.Primary.dark))
                            .fontWeight(.bold)
                        
                        Text("\(viewStore.infoData!.totalMediaCount ?? 0) \(viewStore.infoData!.mediaType)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, -60)
            .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
        }
    }
    
    @ViewBuilder
    func ExtraInfo(viewStore: ViewStoreOf<InfoDomain>) -> some View {
        VStack(alignment: .leading) {
            Text(viewStore.infoData!.description)
                .font(.subheadline)
                .lineLimit(9)
                .opacity(0.7)
            
            Toggle(viewStore.isToggleOn ? "Dubbed" : "Subbed",
                   isOn: viewStore.binding(
                    get: \.isToggleOn,
                    send: InfoDomain.Action.setToggle(newValue:)
                )
            )
            .toggleStyle(M3ToggleStyle())
            
            Text(viewStore.infoData!.mediaType)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.vertical, 6)
        }
        .padding(.top, 60)
        .padding(.horizontal, 20)
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(
            url: "",
            store: Store(
                initialState: InfoDomain.State(),
                reducer: InfoDomain()
            )
        )
    }
}
