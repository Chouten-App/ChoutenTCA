//
//  ReaderView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 16.09.23.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct CircularProgressView: View {
    var progress: Double
    
    @StateObject var Colors = DynamicColors.shared
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(hex: Colors.Primary.dark).opacity(0.5),
                    lineWidth: 4
                )
            Circle()
            // 2
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hex: Colors.Primary.dark),
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

//ImageCollectionView(imageUrls: images, currentCellIndex: $pageNumber)

struct ReaderView: View {
    let store: StoreOf<ReaderDomain>
    let url: String
    
    @StateObject var Colors = DynamicColors.shared
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var showUI: Bool = true
    @State var showSettings: Bool = false
    @State var pageNumber: Int = 0
    @State private var offset = CGFloat.zero
    @State var readingMode: ReadingMode = .ltr
    @State var readingModeSelection = 0
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                ZStack {
                    Color(.black)
                    
                    if let images = viewStore.chapterImages?.images {
                        ImageCollectionView(
                            imageUrls: images,
                            readingMode: $readingMode,
                            currentCellIndex: $pageNumber
                        )
                        .flipsForRightToLeftLayoutDirection(readingMode == .rtl ? true : false)
                        .environment(\.layoutDirection, readingMode == .rtl ? .rightToLeft : .leftToRight)
                    } else {
                        VStack {
                            ProgressView()
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                }
            }
            .background(.black)
            .ignoresSafeArea()
            .background {
                if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                    WebView(
                        viewStore: ViewStore(
                            self.store.scope(
                                state: \.webviewState,
                                action: ReaderDomain.Action.webview
                            )
                        ),
                        payload: url
                    ) { result in
                        print(result)
                        viewStore.send(.parseResult(result: result))
                    }
                    .hidden()
                    .frame(maxWidth: 0, maxHeight: 0)
                }
            }
            .onTapGesture {
                showUI.toggle()
            }
            .overlay {
                VStack {
                    HStack(spacing: 20) {
                        Button {
                            // navigate back
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(12)
                                .foregroundColor(Color(hex: Colors.onSurface.dark))
                                .background {
                                    Circle()
                                        .fill(Color(hex: Colors.SurfaceContainer.dark))
                                }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Chapter 1: Prologue")
                                .fontWeight(.bold)
                            
                            
                            Text("Solo leveling")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .opacity(0.7)
                        }
                        
                        Spacer()
                            .background(Color.clear)
                        
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .padding(10)
                                .foregroundColor(Color(hex: Colors.onSurface.dark))
                                .background {
                                    Circle()
                                        .fill(Color(hex: Colors.SurfaceContainer.dark))
                                }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Text("\(pageNumber + 1)/\(viewStore.chapterImages?.images.count ?? 1)")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(hex: Colors.Surface.dark), location: 0.0),
                            Gradient.Stop(color: Color(hex: Colors.Surface.dark).opacity(0.7), location: 0.1),
                            Gradient.Stop(color: .clear, location: 0.2),
                            Gradient.Stop(color: .clear, location: 0.8),
                            Gradient.Stop(color: Color(hex: Colors.Surface.dark), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    .onTapGesture {
                        showUI.toggle()
                    }
                }
                .opacity(showUI ? 1.0 : 0.0)
                .animation(.spring(response: 0.3), value: showUI)
                //.allowsHitTesting(false)
            }
            .overlay(alignment: .bottom) {
                if showSettings {
                    VStack {
                        HStack {
                            Text("Settings")
                            
                            Spacer()
                            
                            Button {
                                showSettings = false
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(6)
                                    .foregroundColor(Color(hex: Colors.onPrimary.dark))
                                    .background {
                                        Circle()
                                            .fill(
                                                Color(hex: Colors.Primary.dark)
                                            )
                                    }
                            }
                        }
                        
                        Picker("Reading Mode", selection: $readingModeSelection) {
                            Text("LTR").tag(0)
                            Text("RTL").tag(1)
                            Text("Vertical").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: readingModeSelection) { new in
                            switch new {
                            case 0:
                                readingMode = .ltr
                            case 1:
                                readingMode = .rtl
                            case 2:
                                readingMode = .vertical
                            case _:
                                break
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 400, alignment: .top)
                    .background(Color(hex: Colors.SurfaceContainer.dark))
                    .cornerRadius(20)
                    .padding()
                    .ignoresSafeArea()
                    .transition(.move(edge: .bottom))
                }
            }
            .foregroundColor(Color(hex: Colors.onSurface.dark))
            .navigationBarBackButtonHidden()
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}


struct ReaderView_Previews: PreviewProvider {
    static var previews: some View {
        ReaderView(
            store: Store(
                initialState: ReaderDomain.State(
                    chapterImages: ChapterImages(
                        images: [
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x1-746048af037c46657cc768149fddfa401c68834789d35579eecc8f1bb104f205.png"),
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x2-04665d25774fb5a82ba6679194d4fbede30d972d808334e7f98784312b173e04.jpg"),
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x3-5dcb54d2bca1110b27bb7547d98b16be45f2de86393cbcc7d633063f7bf2d17d.jpg"),
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x4-e5217db5e4f441e516b4dfea0b732db5c871edb3ff1794684070709eecea21a1.png"),
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x5-f533182efdac3973963da7d458deb50762211c4995f7d6ce99416314ddef655c.png"),
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x6-698ddfccbab5c5de958e1efbadbc51bcfd4632b7b6b495e3bb5c2922309912e0.png"),
                            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x7-1109c741386cb071ba5b3baf1c4aa8bc019c859bd8b733149d1f909359d53cc6.png")
                        ]
                    )
                ),
                reducer: ReaderDomain()
            ),
            url: ""
        )
    }
}
