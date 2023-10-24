//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 12.10.23.
//

import Architecture
import SwiftUI
import ViewComponents
import Shimmer
import Kingfisher
import Search

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

extension DiscoverFeature.View: View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy in
                Group {
                    switch viewStore.state.state {
                    case .notStarted:
                        ScrollView {
                            // Carousel
                            ShimmerCarousel(proxy: proxy)
                                .onTapGesture {
                                    viewStore.send(.view(.setState(newState: .success)))
                                }
                            // loop through HomeData
                            
                            VStack(alignment: .leading) {
                                HStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 80, height: 20)
                                        .shimmering()
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 40, height: 14)
                                        .shimmering()
                                    
                                    Circle()
                                        .frame(height: 14)
                                        .shimmering()
                                }
                                
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(0..<24, id: \.self) { index in
                                            VStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .frame(width: 90, height: 130)
                                                    .shimmering()
                                                
                                                VStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .frame(width: 90, height: 130)
                                                        .shimmering()
                                                        .frame(width: 90, height: 14)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .frame(width: 90, height: 130)
                                                        .shimmering()
                                                        .frame(width: 40, height: 10)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                            
                            VStack(alignment: .leading) {
                                HStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 80, height: 20)
                                        .shimmering()
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 40, height: 14)
                                        .shimmering()
                                    
                                    Circle()
                                        .frame(height: 14)
                                        .shimmering()
                                }
                                
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(0..<12, id: \.self) { index in
                                            VStack {
                                                VStack {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .frame(width: 80, height: 110)
                                                        .shimmering()
                                                    
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .frame(width: 80, height: 110)
                                                        .shimmering()
                                                        .frame(width: 80, height: 12)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                                VStack {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .frame(width: 80, height: 110)
                                                        .shimmering()
                                                    
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .frame(width: 80, height: 110)
                                                        .shimmering()
                                                        .frame(width: 80, height: 12)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                        }
                    case .loading:
                        ScrollView {
                            // Carousel
                            ShimmerCarousel(proxy: proxy)
                            
                            // loop through HomeData
                            VStack(alignment: .leading) {
                                HStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 80, height: 20)
                                        .shimmering()
                                    
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .frame(width: 40, height: 14)
                                        .shimmering()
                                    
                                    Circle()
                                        .frame(height: 14)
                                        .shimmering()
                                }
                                
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(0..<24, id: \.self) { index in
                                            VStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .frame(width: 90, height: 130)
                                                    .shimmering()
                                                
                                                VStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 6)
                                                        .frame(width: 90, height: 130)
                                                        .shimmering()
                                                        .frame(width: 90, height: 14)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                    
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .frame(width: 90, height: 130)
                                                        .shimmering()
                                                        .frame(width: 40, height: 10)
                                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: proxy.size.width, alignment: .leading)
                        }
                    case .error:
                        Text("ERROR")
                    case .success:
                        ZStack(alignment: .top) {
                            Circle()
                                .trim(from: 0.0, to: refreshPercentage(scrollPosition: viewStore.scrollPosition))
                                .stroke(
                                    .indigo,
                                    style: StrokeStyle(
                                        lineWidth: 4,
                                        lineCap: .round
                                    )
                                )
                                .frame(width: 32)
                                .rotationEffect(.degrees(-90))
                                .offset(y: viewStore.scrollPosition.y / 2)
                            
                            ScrollView {
                                VStack {
                                    Carousel(
                                        count: 8,
                                        currentCellIndex: viewStore.binding(
                                            get: \.carouselIndex,
                                            send: { DiscoverFeature.Action.view(.setCarouselIndex(value: $0))}
                                        )
                                    )
                                    .frame(height: 360)
                                    .frame(minWidth: proxy.size.width, maxWidth: proxy.size.width)
                                    .overlay(alignment: .bottomLeading) {
                                        let width = (proxy.size.width - 32) / 8
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(.indigo)
                                            .frame(width: width, height: 4)
                                            .offset(x: width * Double(viewStore.carouselIndex), y: 2)
                                            .padding(.horizontal)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        HStack(alignment: .bottom) {
                                            Text("Title")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                            
                                            Spacer()
                                            
                                            Text("See more")
                                                .font(.caption)
                                                .opacity(0.7)
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .opacity(0.7)
                                        }
                                        .padding(.horizontal)
                                        .padding(.top)
                                        
                                        ScrollView(.horizontal) {
                                            HStack {
                                                ForEach(0..<24, id: \.self) { index in
                                                    VStack {
                                                        KFImage(
                                                            URL(string: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg")
                                                        )
                                                        .onSuccess { _ in
                                                            withAnimation(.easeIn(duration: 0.4)) {
                                                                // Add any animation effect you want here
                                                            }
                                                        }
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 90, height: 130)
                                                        .cornerRadius(12)
                                                        
                                                        VStack(alignment: .leading) {
                                                            Text("Title")
                                                                .font(.subheadline)
                                                                .frame(width: 72, alignment: .leading)
                                                            
                                                            Text("- / -")
                                                                .font(.caption)
                                                                .frame(width: 72, alignment: .leading)
                                                                .opacity(0.7)
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    .frame(maxWidth: proxy.size.width, alignment: .leading)
                                    
                                }
                                .background(
                                    GeometryReader { geometry in
                                    Color.clear
                                        .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("discover")).origin)
                                    }
                                )
                                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                    print(value)
                                    viewStore.send(.view(.setScrollPosition(value)))
                                    
                                    if value.y >= 170 {
                                        viewStore.send(.view(.refresh))
                                    }
                                }
                            }
                            .coordinateSpace(name: "discover")
                        }
                    }
                }
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                .animation(.spring, value: viewStore.state)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .overlay(alignment: .topTrailing) {
                    if !viewStore.searchVisible {
                        Button {
                            viewStore.send(
                                .view(
                                    .setSearchVisible(newValue: true)
                                ),
                                animation: .easeInOut
                            )
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(.regularMaterial)
                                        .frame(width: 32, height: 32)
                                        .matchedGeometryEffect(id: "searchBG", in: animation)
                                }
                                .matchedGeometryEffect(id: "searchIcon", in: animation)
                        }
                        .padding(.horizontal)
                    }
                }
                .overlay {
                    if viewStore.searchVisible {
                        // TODO: Turn into Feature
                        SearchFeature.View(
                            store: store.scope(
                                state: \.search,
                                action: Action.InternalAction.search
                            ),
                            animation: animation
                        )
                    }
                }
            }
            //.namespace(animation)
            .onAppear {
                viewStore.send(.view(.onAppear))
            }
        }
    }
}

// MARK: CAROUSEL

extension DiscoverFeature.View {
    @MainActor
    func TEMPCarousel(proxy: GeometryProxy) -> some View {
        ZStack {
            KFImage(
                URL(string: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg")
            )
            .resizable()
            .aspectRatio(contentMode: .fill)
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Primary")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Secondary")
                            .fontWeight(.semibold)
                            .opacity(0.7)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Icon Text")
                            .font(.caption)
                        
                        Image(systemName: "star.fill")
                            .font(.caption)
                    }
                }
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    .font(.subheadline)
                    .lineLimit(3)
                    .opacity(0.7)
            }
            .padding()
            .frame(width: proxy.size.width, height: 360, alignment: .bottomLeading)
            .background {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.7), location: 0.0),
                        .init(color: .black.opacity(0.0), location: 1.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
        }
        .frame(width: proxy.size.width, height: 360)
    }
    
    func ShimmerCarousel(proxy: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .frame(width: proxy.size.width, height: 360)
                .shimmering()
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 80, height: 24)
                            .shimmering()
                        
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 100, height: 18)
                            .opacity(0.7)
                            .shimmering()
                    }
                    
                    Spacer()
                    
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: 40, height: 12)
                            .shimmering()
                        
                        Circle()
                            .frame(width: 12)
                            .shimmering()
                    }
                }
                
                
                VStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: proxy.size.width - 32, height: 15)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: proxy.size.width - 32, height: 15)
                        .shimmering()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: proxy.size.width - 80, height: 15)
                        .shimmering()
                }
                .opacity(0.7)
            }
            .padding()
            .frame(width: proxy.size.width, height: 360, alignment: .bottomLeading)
            .background {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.7), location: 0.0),
                        .init(color: .black.opacity(0.0), location: 1.0)
                        
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
        }
        .frame(width: proxy.size.width, height: 360)
    }
}

#Preview("Discover") {
    DiscoverFeature.View(
        store: .init(
            initialState: .init(),
            reducer: { DiscoverFeature() }
        )
    )
}
