//
//  SearchView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import ActivityIndicatorView
import SwiftUISnackbar

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct SearchViewiOS: View {
    let store: StoreOf<SearchDomain>
    @StateObject var Colors = DynamicColors.shared
    
    @Dependency(\.DownloadManager) var downloadManager
    
    // TEMP
    @State private var scrollPosition: CGPoint = .zero
    @State var blink = false
    @State private var shouldRunCodeRandomly = false
    
    func searchTitleOpacity() -> CGFloat {
        if scrollPosition.y < -60 { return 0 }
        
        return 1.0 - (scrollPosition.y / CGFloat(-60))
    }
    
    // Function to load UIImage from a local file URL
    func loadImageFromURL(_ urlString: String) -> UIImage {
        guard let imageUrl = URL(string: urlString),
              let imageData = try? Data(contentsOf: imageUrl),
              let uiImage = UIImage(data: imageData) else {
            // Return a placeholder image or handle the error as needed
            return UIImage(systemName: "photo") ?? UIImage()
        }
        return uiImage
    }
    
    var body: some View {
        GeometryReader { proxy in
            WithViewStore(self.store) { viewStore in
                VStack {
                    Group {
                        if viewStore.loadingStatus == .loading {
                            VStack {
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), alignment: .top)
                                ], spacing: 20) {
                                    ForEach(0..<16, id: \.self) { index in
                                        VStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .frame(width: 110, height: 160)
                                                .shimmer(
                                                    delay: 0.2 * Double(index)
                                                )
                                            
                                            RoundedRectangle(cornerRadius: 6)
                                                .frame(width: 110, height: 16)
                                                .shimmer(
                                                    delay: 0.1 + ( 0.2 * Double(index) )
                                                )
                                            
                                            HStack {
                                                Spacer()
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .frame(width: 40, height: 12)
                                                    .shimmer(
                                                        delay: 0.2 + ( 0.2 * Double(index) )
                                                    )
                                            }
                                            .frame(width: 110)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 190)
                            .padding(.bottom, 120)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewStore.loadingStatus == .success {
                            if viewStore.searchResult.count == 0 {
                                AsciimoteView(
                                    "(×﹏×)",
                                    description: "Seems like your search didn't match anything. Please try a different search query."
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            } else {
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
                                                    ZStack(alignment: .topTrailing) {
                                                        if viewStore.searchResult[index].img.contains("https://") {
                                                            KFImage(URL(string: viewStore.searchResult[index].img))
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 110, height: 160)
                                                                .cornerRadius(12)
                                                        } else {
                                                            KFImage(URL(fileURLWithPath: viewStore.searchResult[index].img))
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fill)
                                                                .frame(width: 110, height: 160)
                                                                .frame(minWidth: 110, minHeight: 160)
                                                                .cornerRadius(12)
                                                        }
                                                        
                                                        if let indicatorText = viewStore.searchResult[index].indicatorText {
                                                            Text(indicatorText)
                                                                .font(.caption)
                                                                .fontWeight(.semibold)
                                                                .padding(.vertical, 2)
                                                                .padding(.horizontal, 8)
                                                                .foregroundColor(Color(hex: Colors.onPrimary.dark))
                                                                .background {
                                                                    Capsule()
                                                                        .fill(
                                                                            Color(hex: Colors.Primary.dark)
                                                                        )
                                                                }
                                                                .padding(8)
                                                        }
                                                    }
                                                    .frame(width: 110, height: 160)
                                                    .frame(minWidth: 110, minHeight: 160)
                                                    
                                                    Text(viewStore.searchResult[index].title)
                                                        .frame(width: 90, alignment: .leading)
                                                        .lineLimit(1)
                                                    
                                                    Text("\(viewStore.searchResult[index].currentCountString) / \(viewStore.searchResult[index].totalCountString)")
                                                        .font(.caption)
                                                        .frame(width: 86, alignment: .leading)
                                                        .opacity(0.7)
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
                                    .padding(.top, viewStore.isDownloadedOnly ? 130 : 190)
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
                                        scrollPosition = value
                                    }
                                }
                                .coordinateSpace(name: "scroll")
                            }
                        } else if viewStore.loadingStatus == .error {
                            AsciimoteView(
                                "(×﹏×)",
                                description: viewStore.isDownloadedOnly ? "Nothing found in your Library" : "Nothing was found with that query. Please try a different search term."
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            AsciimoteView(
                                "(         ) ?",
                                description: "Why not try to search for something?"
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay {
                                HStack(spacing: 28) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: Colors.onSurface.dark))
                                        .frame(width: 6, height: blink ? 3 : 6)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color(hex: Colors.onSurface.dark))
                                        .frame(width: 6, height: blink ? 3 : 6)
                                }
                                .offset(x: -17, y: -20)
                                .onAppear {
                                    // Start a Timer that fires every second
                                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                        // Generate a random number between 0 and 1
                                        let randomValue = Double.random(in: 0...1)
                                        
                                        // Set a threshold for randomness (e.g., 0.5 for 50% chance)
                                        let randomnessThreshold: Double = 0.5
                                        
                                        // Check if the random number is less than the threshold
                                        if randomValue < randomnessThreshold {
                                            // Set the flag to indicate that code should run randomly
                                            shouldRunCodeRandomly = true
                                        }
                                        
                                        // Check if the flag is true, and if so, execute your code
                                        if shouldRunCodeRandomly {
                                            withAnimation {
                                                blink = true
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                withAnimation {
                                                    blink = false
                                                }
                                                
                                                shouldRunCodeRandomly = false
                                            }
                                        }
                                    }
                                }
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
                            ),
                            payload: viewStore.query
                        ) { result in
                            viewStore.send(.parseResult(data: result))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
                .overlay(alignment: .top) {
                    VStack {
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
                        .opacity(searchTitleOpacity())
                        
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
                                    .tint(Color(hex: Colors.Primary.dark))
                                    .disableAutocorrection(true)
                                    .onSubmit {
                                        if viewStore.isDownloadedOnly {
                                            let results = downloadManager.searchLocally(viewStore.query)
                                            
                                            viewStore.send(.setSearchResult(results: results))
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
                            
                            if viewStore.query != viewStore.oldQuery {
                                Button {
                                    viewStore.send(.setQuery(query: viewStore.oldQuery))
                                } label: {
                                    Text("Cancel")
                                        .foregroundColor(Color(hex: Colors.onSurface.dark))
                                }
                                
                                
                            }
                        }
                    }
                    .padding(20)
                    .padding(.top, viewStore.isDownloadedOnly ? 0 : proxy.safeAreaInsets.top)
                    .padding(.top, scrollPosition.y < -60 ? -60 : scrollPosition.y)
                    .background {
                        Color(hex: Colors.Surface.dark)
                    }
                    .animation(.spring(response: 0.3), value: viewStore.query)
                }
                .ignoresSafeArea()
                .onAppear {
                    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                        viewStore.send(.onAppear)
                    }
                }
            }
        }
    }
}

struct SearchViewiOS_Previews: PreviewProvider {
    static var previews: some View {
        SearchViewiOS(
            store: Store(initialState: SearchDomain.State(
                loadingStatus: .notStarted,
                searchResult: [
                    SearchData(url: "", img: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg", title: "Title", indicatorText: "18+", currentCount: 12, totalCount: 12),
                    SearchData(url: "", img: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg", title: "Title", indicatorText: "18+", currentCount: 12, totalCount: 12),
                ]
            ), reducer: SearchDomain())
        )
    }
}
