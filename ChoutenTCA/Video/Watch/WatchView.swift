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
    @FetchRequest(sortDescriptors: []) var mediaProgress: FetchedResults<MediaProgress>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            CustomPlayerWithControls(
                streamData: viewStore.binding(
                    get: \.videoData,
                    send: WatchDomain.Action.setVideoData(newValue:)
                ),
                index: index,
                playerVM: playerVM
            )
            .navigationBarBackButtonHidden(true)
            .contentShape(Rectangle())
            .ignoresSafeArea(.all)
            .edgesIgnoringSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .supportedOrientation(.landscape)
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
            .onChange(of: viewStore.nextUrl) { newValue in
                if newValue != nil {
                    viewStore.send(.resetWebviewChange(url: newValue!))
                }
            }
            .onChange(of: viewStore.videoData) { data in
                if data != nil {
                    playerVM.setCurrentItem(
                        AVPlayerItem(
                            url: URL(
                                string: data!.sources[0].file
                            )!
                        )
                    )
                    if(data!.subtitles.count > 0) {
                        var content: String
                        var index = 0
                        
                        for sub in 0..<data!.subtitles.count {
                            if(data!.subtitles[sub].language == "English") {
                                index = sub
                            }
                        }
                        
                        playerVM.selectedSubtitleIndex = index
                        
                        if let url = URL(string: data!.subtitles[index].url) {
                            do {
                                content = try String(contentsOf: url)
                            } catch {
                                // contents could not be loaded
                                content = ""
                            }
                        } else {
                            // the URL was bad!
                            content = ""
                        }
                        
                        let parser = WebVTTParser(
                            string: content
                                .replacingOccurrences(of: "<i>", with: "_")
                                .replacingOccurrences(of: "</i>", with: "_")
                                .replacingOccurrences(of: "<b>", with: "*")
                                .replacingOccurrences(of: "</b>", with: "*")
                        )
                        let webVTT = try? parser.parse()
                        
                        playerVM.webVTT = webVTT
                    }
                    
                    if let mediaData: MediaItem = viewStore.infoData?.mediaList.first?.list[index] {
                        var prog = mediaProgress.filter { progress in
                            progress.url == self.url && progress.number == mediaData.number
                        }.first
                        
                        if prog != nil {
                            playerVM.isEditingCurrentTime = true
                            playerVM.currentTime = prog!.progress
                            playerVM.isEditingCurrentTime = false
                        }
                    }
                    
                    playerVM.player.play()
                }
            }
            .onChange(of: playerVM.currentTime) { newValue in
                if let mediaData: MediaItem = viewStore.infoData?.mediaList.first?.list[index] {
                    var progress = mediaProgress.filter { progress in
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
        .prefersHomeIndicatorAutoHidden(true)
        .supportedOrientation(.landscape)
        .previewInterfaceOrientation(.landscapeRight)
    }
}
