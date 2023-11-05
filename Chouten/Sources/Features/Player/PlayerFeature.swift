//
//  File.swift
//  
//
//  Created by Inumaki on 16.10.23.
//

import Architecture
import ComposableArchitecture
import SwiftUI
import AVKit
import Webview
import SharedModels
import ModuleClient
import DataClient

public struct PlayerFeature: Feature {
    @Dependency(\.dataClient) var dataClient
    @Dependency(\.moduleClient) var moduleClient
    
    public struct State: FeatureState {
        public let url: String
        public var infoData: InfoData? = nil
        
        public var fullscreen: Bool = (UIScreen.main.bounds.width / UIScreen.main.bounds.height) > 1
        
        public var webviewState: WebviewFeature.State
        
        public var videoLoadable: Loadable<VideoData> = .pending
        
        public var speed: Float = 1.0
        public var server: String = "Vidstreaming (Sub)"
        public var quality: String = "auto"
        
        public var servers: [ServerData] = []
        
        public var qualities: [String: String] = [
            "240p": "https://test-streams.mux.dev/x36xhzz/url_2/193039199_mp4_h264_aac_ld_7.m3u8", // 240p
            "360p": "https://test-streams.mux.dev/x36xhzz/url_4/193039199_mp4_h264_aac_7.m3u8", // 360p
            "480p": "https://test-streams.mux.dev/x36xhzz/url_6/193039199_mp4_h264_aac_hq_7.m3u8", // 480p
            "720p": "https://test-streams.mux.dev/x36xhzz/url_0/193039199_mp4_h264_aac_hd_7.m3u8", // 720p
            "1080p": "https://test-streams.mux.dev/x36xhzz/url_8/193039199_mp4_h264_aac_fhd_7.m3u8", // 1080p
            "Auto": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8" // auto
        ]
        
        public var showMenu: Bool = false
        
        public init(url: String = "") {
            self.url = url
            self.webviewState = WebviewFeature.State(htmlString: "", javaScript: "")
        }
    }
    
    public enum Action: FeatureAction {
        public enum ViewAction: SendableAction {
            case setPiP(_ value: Bool)
            case setSpeed(value: Float)
            case setServer(value: String)
            case setQuality(value: String)
            case setShowMenu(_ value: Bool)
            
            case navigateBack
            
            case setQualityDict(_ dict: [String: String])
            case setFullscreen(_ value: Bool)
            
            case onAppear
            case resetWebviewChange
            case parseResult(data: String)
            case parseVideoResult(data: String)
            case setServers(data: [ServerData])
            case setVideoData(data: VideoData)
        }
        public enum DelegateAction: SendableAction {}
        public enum InternalAction: SendableAction {
            case webview(WebviewFeature.Action)
        }

        case view(ViewAction)
        case delegate(DelegateAction)
        case `internal`(InternalAction)
    }
    
    @MainActor
    public struct View: FeatureView {
        public let store: StoreOf<PlayerFeature>
        
        @StateObject var playerVM = PlayerViewModel()
        
        func secondsToMinutesSeconds(_ seconds: Int) -> String {
            let hours = (seconds / 3600)
            let minutes = (seconds % 3600) / 60
            let seconds = (seconds % 3600) % 60
            
            let hourString = hours > 0 ? "\(hours)" : ""
            let minuteString = (minutes < 10 ? "0" : "") +  "\(minutes)"
            let secondsString = (seconds < 10 ? "0" : "") +  "\(seconds)"
            
            return (hours > 0 ? hourString + ":" : "") + minuteString + ":" + secondsString
        }

        public nonisolated init(store: StoreOf<PlayerFeature>) {
            self.store = store
        }
    }

    public init() {}
}
