//
//  WatchView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import SwiftUI
import ComposableArchitecture
import AVKit
import SwiftWebVTT

struct WatchView: View {
    let url: String
    let index: Int
    let store: StoreOf<WatchDomain>
    @StateObject var playerVM: PlayerViewModel = PlayerViewModel()
    @StateObject var Colors = DynamicColors.shared
    @FetchRequest(sortDescriptors: []) var mediaProgress: FetchedResults<MediaProgress>
    @Environment(\.managedObjectContext) var moc
    
    @State var subtitleDelegate: InterceptingAssetResourceLoaderDelegate? = nil
    @State var isFullscreen: Bool = false
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { proxy in
                VStack {
                    ZStack {
                        /*
                        CustomVideoPlayer(playerVM: playerVM, showUI: false, scaledVideo: .constant(false))
                            .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.width / 16 * 9)
                            .clipped()
                            .blur(radius: 12)
                            .scaleEffect(1.2)
                            .opacity(0.3)
                        */
                        
                        CustomPlayerWithControls(
                            streamData: viewStore.binding(
                                get: \.videoData,
                                send: WatchDomain.Action.setVideoData(newValue:)
                            ),
                            servers: viewStore.binding(
                                get: \.servers,
                                send: WatchDomain.Action.setServers(newValue:)
                            ),
                            index: index,
                            playerVM: playerVM,
                            isFullscreen: $isFullscreen
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: isFullscreen ?
                                .infinity :
                                proxy.size.width / 16 * 9
                        )
                        .clipped()
                    }
                    
                    if !isFullscreen {
                        ScrollView {
                            if let infoData = viewStore.infoData {
                                VStack(alignment: .leading, spacing: 12) {
                                    // Info
                                    VStack(alignment: .leading) {
                                        Text(infoData.titles.primary)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .lineLimit(2)
                                        if let secondary = infoData.titles.secondary {
                                            Text(secondary)
                                                .font(.caption)
                                                .fontWeight(.heavy)
                                                .lineLimit(2)
                                                .opacity(0.7)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 6)
                                    
                                    Text(infoData.description)
                                        .font(.subheadline)
                                        .lineLimit(9)
                                        .opacity(0.7)
                                        .padding(.vertical, 6)
                                        .contentShape(Rectangle())
                                        .padding(.horizontal, 20)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack {
                                            Text("Season 1")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .padding(6)
                                                .background {
                                                    Circle()
                                                        .fill(Color(hex: Colors.SurfaceContainer.dark))
                                                }
                                        }
                                        .contentShape(Rectangle())
                                        
                                        HStack {
                                            Text("\(infoData.totalMediaCount ?? 0) \(infoData.mediaType)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .opacity(0.7)
                                            
                                            Spacer()
                                            
                                            Image("arrow.down.filter")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .foregroundColor(.white)
                                                .opacity(0.7)
                                                .contentShape(Rectangle())
                                            
                                            Image("arrow.down.filter")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .scaleEffect(CGSize(width: 1.0, height: -1.0))
                                                .foregroundColor(.white)
                                                .opacity(1.0)
                                                .contentShape(Rectangle())
                                        }
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 20)
                                    
                                    // Episode List
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isFullscreen ? .center : .top)
                .background(Color(hex: Colors.Surface.dark))
                .foregroundColor(Color(hex: Colors.onSurface.dark))
                .edgesIgnoringSafeArea(isFullscreen ? .all : .bottom)
            }
            .navigationBarBackButtonHidden(true)
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .background {
                if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                    if viewStore.servers.count > 0 {
                        WebView(
                            viewStore: ViewStore(
                                self.store.scope(
                                    state: \.webviewState,
                                    action: WatchDomain.Action.webview
                                )
                            ),
                            payload: viewStore.servers[0].list[0].url,
                            action: "video"
                        ) { result in
                            print(result)
                            //viewStore.send(.parseResult(data: result))
                            viewStore.send(.parseMediaResult(data: result))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    } else {
                        WebView(
                            viewStore: ViewStore(
                                self.store.scope(
                                    state: \.webviewState,
                                    action: WatchDomain.Action.webview
                                )
                            ),
                            payload: self.url
                        ) { result in
                            print(result)
                            viewStore.send(.parseResult(data: result))
                            viewStore.send(.resetWebviewChange(url: self.url))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
            }
            .onAppear {
                print(url)
                viewStore.send(.resetWebview(url: url))
            }
            .onDisappear {
                viewStore.send(.resetWatchpage)
            }
            .onChange(of: viewStore.videoData) { data in
                if let data {
                    let auto = data.sources.first(where: { $0.quality == "auto" })
                    
                    var subs: [VideoCompositionItem.SubtitleINTERNAL] = []
                    
                    if !data.subtitles.isEmpty {
                        subs.append(VideoCompositionItem.SubtitleINTERNAL(
                            name: data.subtitles.filter({ $0.language.contains("English") })[0].language,
                            default: true,
                            autoselect: true,
                            link: URL(string: data.subtitles.filter({ $0.language.contains("English") })[0].url)!
                        ))
                    }
                    
                    let item = PlayerItem(
                        VideoCompositionItem(
                            link: URL(string: auto?.file ?? "")!,
                            headers: data.headers ?? [:],
                            subtitles: subs
                        )
                    )
                    
                    playerVM.setCurrentItem(item)
                    /*
                    if let mediaData: MediaItem = viewStore.infoData?.mediaList.first?.list[index] {
                        let prog = mediaProgress.filter { progress in
                            progress.url == self.url && progress.number == mediaData.number
                        }.first
                        
                        if prog != nil {
                            playerVM.isEditingCurrentTime = true
                            playerVM.currentTime = prog!.progress
                            playerVM.isEditingCurrentTime = false
                        }
                    }
                     */
                    
                    playerVM.player.play()
                }
            }
            .onChange(of: playerVM.currentTime) { newValue in
                /*
                if let mediaData: MediaItem = viewStore.infoData?.mediaList.first?.list[index] {
                    let progress = mediaProgress.filter { progress in
                        progress.url == self.url && progress.number == mediaData.number
                    }.first
                    
                    if progress == nil {
                        let prog = MediaProgress(context: moc)
                        prog.url = self.url
                        prog.progress = playerVM.currentTime
                        prog.duration = playerVM.duration ?? 1.0
                        prog.number = mediaData.number
                        try? moc.save()
                    } else {
                        progress!.progress = playerVM.currentTime
                        progress!.duration = playerVM.duration ?? 1.0
                        progress!.number = mediaData.number
                        try? moc.save()
                    }
                }
                 */
            }
        }
    }
}

struct WatchView_Previews: PreviewProvider {
    static var previews: some View {
        WatchView(
            url: "",
            index: 0,
            store: Store(
                initialState: WatchDomain.State(),
                reducer: WatchDomain()
            )
        )
        .previewInterfaceOrientation(.landscapeRight)
        .prefersHomeIndicatorAutoHidden(true)
    }
}
