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
    @State var index: Int
    @StateObject var playerVM: PlayerViewModel
    @State var doneLoading = false
    @State var showUI: Bool = true
    @State var resIndex: Int = 0
    @State var animateBackward: Bool = false
    @State var animateForward: Bool = false
    
    @State var scaledVideo = true
    
    init(streamData: Binding<VideoData?>, index: Int, playerVM: PlayerViewModel) {
        self._streamData = streamData
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
                        VideoControlsView(videoData: $streamData, index: index, playerVM: playerVM)
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
        CustomPlayerWithControls(streamData: .constant(VideoData(sources: [Source(file: "https://c-an-ca3.betterstream.cc:2223/hls-playback/6bad66e945c851b0ce0cda2d993bd6ab0f177e531d132d4b68d66ba95f6fbabf0193efeb286abd5cef6b6344c610b3dfc07ba364b3378488227ad23db63b79f04866e615efdc8479f753564fa38214df759adbdbf74e3d937b6ecaea8c076519892f7f14265be674f2dd5cec638386597fabc08c943ceafd8e11e2758f4d7f810a03d929e664765c20ecf603ae886d28/index-f1-v1-a1.m3u8", type: "hls", quality: "1080p")], subtitles: [], skips: [])), index: 0, playerVM: PlayerViewModel())
            .supportedOrientation(.landscapeRight)
            .previewInterfaceOrientation(.landscapeRight)
    }
}
