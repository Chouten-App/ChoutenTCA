//
//  CustomPlayerWithControls.swift
//  ChoutenTCA
//
//  Created by Inumaki on 02.06.23.
//

import SwiftUI
import AVKit

struct CustomPlayerWithControls: View {
    @Binding var streamData: VideoData?
    @Binding var servers: [ServerData]
    @State var index: Int
    @StateObject var playerVM: PlayerViewModel
    @State var doneLoading = false
    @State var showUI: Bool = true
    @State var resIndex: Int = 0
    @State var animateBackward: Bool = false
    @State var animateForward: Bool = false
    
    @State var scaledVideo = true
    
    init(streamData: Binding<VideoData?>, servers: Binding<[ServerData]>, index: Int, playerVM: PlayerViewModel) {
        self._streamData = streamData
        self._servers = servers
        self.index = index
        self._playerVM = StateObject(wrappedValue: playerVM)
        // we need this to use Picture in Picture
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    private var isIOS16: Bool {
        guard #available(iOS 16, *) else {
            return true
        }
        return false
    }
    
    var body: some View {
        GeometryReader {proxy in
            ZStack {
                Color(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea(.all)
                
                CustomVideoPlayer(playerVM: playerVM, showUI: showUI, scaledVideo: $scaledVideo)
                    .frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height, alignment: .center)
                    .ignoresSafeArea()
                    .overlay {
                        VideoControlsView(videoData: $streamData, servers: $servers, index: index, playerVM: playerVM)
                    }
                    .gesture(
                        MagnificationGesture()
                            .onEnded { value in
                                // Perform any necessary actions after the gesture ends
                                print(value)
                                if value > 2 {
                                    scaledVideo = false
                                } else if value < 1 {
                                    scaledVideo = true
                                }
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea(.all)
            .prefersHomeIndicatorAutoHidden(true)
            .onDisappear {
                print("bye")
                playerVM.player.pause()
                
                playerVM.player.replaceCurrentItem(with: nil)
            }
        }
    }
}

struct CustomPlayerWithControls_Previews: PreviewProvider {
    static var previews: some View {
        CustomPlayerWithControls(streamData: .constant(VideoData(sources: [Source(file: "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8", type: "hls", quality: "1080p")], subtitles: [], skips: [], headers: nil)), servers: .constant([]), index: 0, playerVM: PlayerViewModel())
            .supportedOrientation(.landscapeRight)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
