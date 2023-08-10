//
//  HomeView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeDomain>
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                ScrollView {
                    if !viewStore.homeData.isEmpty {
                        VStack {
                            Carousel(viewStore: viewStore, component: viewStore.homeData[0], proxy: proxy)
                                .padding(.bottom, 110)
                            
                            ForEach(1..<viewStore.homeData.count) { index in
                                if viewStore.homeData[index].type == "list" {
                                    List(component: viewStore.homeData[index], proxy: proxy)
                                } else if viewStore.homeData[index].type == "grid_2x" {
                                    Grid2x(component: viewStore.homeData[index], proxy: proxy)
                                }
                            }
                        }
                        .padding(.bottom, 120)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .ignoresSafeArea()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                    action: HomeDomain.Action.webview
                                )
                            )
                        ) { result in
                            viewStore.send(.parseResult(data: result))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .ignoresSafeArea()
            }
            .onAppear {
                viewStore.send(.resetWebview)
            }
        }
    }
    
    @ViewBuilder
    func Carousel(viewStore: ViewStoreOf<HomeDomain>, component: HomeComponent, proxy: GeometryProxy) -> some View {
        TabView(selection: viewStore.binding(
            get: \.carouselIndex,
            send: HomeDomain.Action.setCarouselIndex(newIndex:)
        )) {
            ForEach(0..<component.data.count, id: \.self) { index in
                KFImage(URL(string: component.data[index].image))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: proxy.size.width, minHeight: 420, maxHeight: 420)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(
                                    color: Color(hex: Colors.Surface.dark).opacity(0.0),
                                    location: 0.0
                                ),
                                Gradient.Stop(
                                    color: Color(hex: Colors.Surface.dark).opacity(0.9),
                                    location: 1.0
                                )
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(minHeight: 360,maxHeight: 360, alignment: .top)
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                HStack {
                    Text(component.data[viewStore.carouselIndex].indicator ?? "")
                        .foregroundColor(Color(hex: Colors.onPrimary.dark))
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 3)
                        .background {
                            Capsule()
                                .fill(
                                    Color(hex: Colors.Primary.dark)
                                )
                        }
                    Spacer()
                    Text(component.data[viewStore.carouselIndex].iconText ?? "")
                        .fontWeight(.semibold)
                    
                    if component.data[viewStore.carouselIndex].showIcon {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: Colors.Tertiary.dark))
                    }
                }
                
                Text(component.data[viewStore.carouselIndex].titles.primary)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(3)
                if component.data[viewStore.carouselIndex].titles.secondary != nil {
                    Text(component.data[viewStore.carouselIndex].titles.secondary!)
                        .font(.headline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .opacity(0.7)
                }
                
                Spacer()
                
                HStack(alignment: .top) {
                    Text(component.data[viewStore.carouselIndex].subtitle)
                    
                    if component.data[viewStore.carouselIndex].subtitleValue.count > 0 {
                        Text(component.data[viewStore.carouselIndex].subtitleValue.joined(separator: " • "))
                            .fontWeight(.bold)
                            .lineLimit(1)
                    }
                    
                }
                .font(.subheadline)
                
                Spacer()
                
                HStack {
                    NavigationLink(
                        destination: InfoView(
                            url: component.data[viewStore.carouselIndex].url,
                            store: self.store.scope(
                                state: \.infoState,
                                action: HomeDomain.Action.info
                            )
                        )
                    ) {
                        Text(component.data[viewStore.carouselIndex].buttonText)
                            .foregroundColor(Color(hex: Colors.Tertiary.dark))
                            .fontWeight(.semibold)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus")
                        .foregroundColor(Color(hex: Colors.onPrimary.dark))
                        .padding(6)
                        .background {
                            Circle()
                                .fill(Color(hex: Colors.Primary.dark))
                        }
                }
            }
            .foregroundColor(Color(hex: Colors.onSurface.dark))
            .padding(20)
            .frame(maxWidth: proxy.size.width, maxHeight: 220, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: Colors.SurfaceContainer.dark))
            }
            .shadow(radius: 12)
            .padding(.horizontal, 12)
            .offset(y: 100)
        }
    }
    
    @ViewBuilder
    func Grid2x(component: HomeComponent, proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text(component.title)
                .font(.title3)
                .fontWeight(.bold)
            
            ScrollView(.horizontal) {
                LazyHGrid(rows: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(0..<component.data.count) {gridIndex in
                        NavigationLink(
                            destination: InfoView(
                                url: component.data[gridIndex].url,
                                store: self.store.scope(
                                    state: \.infoState,
                                    action: HomeDomain.Action.info
                                )
                            )
                        ) {
                            VStack {
                                KFImage(URL(string: component.data[gridIndex].image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 280)
                                    .cornerRadius(6)
                                
                                Text(component.data[gridIndex].titles.primary)
                                    .frame(maxWidth: 80)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .frame(maxHeight: 600)
                .padding(.trailing, 20)
            }
            .frame(maxWidth: proxy.size.width)
            .padding(.trailing, -20)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func List(component: HomeComponent, proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            Text(component.title)
                .font(.title3)
                .fontWeight(.bold)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<component.data.count) { listIndex in
                        NavigationLink(
                            destination: InfoView(
                                url: component.data[listIndex].url,
                                store: self.store.scope(
                                    state: \.infoState,
                                    action: HomeDomain.Action.info
                                )
                            )
                        ) {
                            VStack {
                                KFImage(URL(string: component.data[listIndex].image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 110, height: 160)
                                    .cornerRadius(12)
                                
                                Text(component.data[listIndex].titles.primary)
                                    .frame(width: 110)
                                    .lineLimit(1)
                                
                                HStack {
                                    Spacer()
                                    
                                    Text(
                                        (component.data[listIndex].current != nil ? String(component.data[listIndex].current!) : "~") + " / " + (component.data[listIndex].total != nil ? String(component.data[listIndex].total!) : "~")
                                    )
                                    .font(.caption)
                                }
                                .frame(width: 110)
                            }
                            .frame(maxWidth: 110)
                        }
                    }
                }
                .padding(.trailing, 20)
            }
            .frame(maxWidth: proxy.size.width)
            .padding(.trailing, -20)
        }
        .padding(.horizontal, 20)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: Store(
                initialState: HomeDomain.State(),
                reducer: HomeDomain()
            )
        )
    }
}
