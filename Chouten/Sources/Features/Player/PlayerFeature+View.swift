//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 16.10.23.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import AVKit
import Combine
import ViewComponents
import Webview
import Architecture
import SharedModels
import GRDB

struct Seekbar: View {
    @Binding var percentage: Double // or some value binded
    @Binding var buffered: Double
    @Binding var isDragging: Bool
    var total: Double
    @State var barHeight: CGFloat = 6
    
    var body: some View {
        GeometryReader { geometry in
            // TODO: - there might be a need for horizontal and vertical alignments
            ZStack(alignment: .bottomLeading) {
                
                Capsule()
                    .foregroundColor(.gray).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                
                Capsule()
                    .foregroundColor(.white.opacity(0.4))
                    .frame(
                        maxWidth: geometry.size.width
                    )
                    .frame(height: barHeight, alignment: .bottom)
                    .offset(
                        x: -geometry.size.width + (
                            geometry.size.width
                            * CGFloat(self.buffered / total)
                        )
                    )
                
                Capsule()
                    .foregroundColor(.indigo)
                    .frame(
                        maxWidth: geometry.size.width
                    )
                    .frame(height: barHeight, alignment: .bottom)
                    .offset(
                        x: -geometry.size.width + (
                            geometry.size.width
                            * CGFloat(self.percentage / total)
                        )
                    )
            }
            .frame(height: barHeight)
            .clipShape(Capsule())
            .frame(maxHeight: .infinity, alignment: .center)
            .overlay {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                                self.isDragging = false
                                self.barHeight = 6
                            }
                            .onChanged{ value in
                                self.isDragging = true
                                self.barHeight = 10
                                // TODO: - maybe use other logic here
                                self.percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                            }
                    )
            }
            .animation(.spring(response: 0.3), value: self.isDragging)
        }
        
    }
}

struct SeekbarBridge: View {
    @State var dragging = false
    @State var buffered = 0.7
    @State var progress = 0.0
    
    var body: some View {
        Seekbar(percentage: $progress, buffered: $buffered, isDragging: $dragging, total: 1.0)
            .frame(maxHeight: 24)
            .padding(.horizontal)
    }
}

#Preview("Seekbar") {
    SeekbarBridge()
}

class PlayerView: UIView {
    
    // Override the property to make AVPlayerLayer the view's backing layer.
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    // The associated player object.
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

extension PlayerView {
    func hideSubtitles(_ hide: Bool) {
        guard let currentItem = player?.currentItem else { return }
        
        if hide {
            // Hide subtitles by creating a transparent text style rule
            let transparentBackgroundColor = UIColor.clear.cgColor
            let backgroundColorAttribute = NSAttributedString.Key.backgroundColor.rawValue
            
            let transparentStyle = AVTextStyleRule(textMarkupAttributes: [backgroundColorAttribute: transparentBackgroundColor])
            
            // Create an array to hold the transparentStyle
            currentItem.textStyleRules = [transparentStyle].compactMap { $0 }
        } else {
            // Show subtitles by removing all text style rules
            currentItem.textStyleRules = []
        }
    }
}




final class PlayerViewModel: ObservableObject {
    let player = AVPlayer()
    @Published var isInPipMode: Bool = false
    @Published var isPlaying = false
    
    @Published var isEditingCurrentTime = false
    @Published var currentTime: Double = .zero
    @Published var duration: Double?
    
    private var subscriptions: Set<AnyCancellable> = []
    private var timeObserver: Any?
    
    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }
    
    func setAudioSessionCategory(to value: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(value)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    init() {
        setAudioSessionCategory(to: .playback)
        $isEditingCurrentTime
            .dropFirst()
            .filter({ $0 == false })
            .sink(receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.player.seek(to: CMTime(seconds: self.currentTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                if self.player.rate != 0 {
                    self.player.play()
                }
            })
            .store(in: &subscriptions)
        
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.isEditingCurrentTime == false {
                self.currentTime = time.seconds
            }
        }
    }
    
    func setCurrentItem(_ item: AVPlayerItem) {
        currentTime = .zero
        duration = nil
        player.replaceCurrentItem(with: item)
        
        item.publisher(for: \.status)
            .filter({ $0 == .readyToPlay })
            .sink(receiveValue: { [weak self] _ in
                self?.duration = item.asset.duration.seconds
            })
            .store(in: &subscriptions)
    }
}

struct CustomVideoPlayer: UIViewRepresentable {
    @ObservedObject var playerVM: PlayerViewModel
    
    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = playerVM.player
        context.coordinator.setController(view.playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: PlayerView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        private let parent: CustomVideoPlayer
        private var controller: AVPictureInPictureController?
        private var cancellable: AnyCancellable?
        private var subtitlesHidden = false
        
        init(_ parent: CustomVideoPlayer) {
            self.parent = parent
            super.init()
            
            cancellable = parent.playerVM.$isInPipMode
                .sink { [weak self] in
                    guard let self = self,
                          let controller = self.controller else { return }
                    if $0 {
                        if controller.isPictureInPictureActive == false {
                            controller.startPictureInPicture()
                        }
                    } else if controller.isPictureInPictureActive {
                        controller.stopPictureInPicture()
                    }
                }
        }
        
        func setController(_ playerLayer: AVPlayerLayer) {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            controller?.canStartPictureInPictureAutomaticallyFromInline = true
            controller?.delegate = self
        }
        
        func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            parent.playerVM.isInPipMode = true
        }
        
        func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
            parent.playerVM.isInPipMode = false
        }
    }
}

extension PlayerFeature.View {
    @MainActor
    public var body: some View {
        WithViewStore(store, observe: \.`self`) { viewStore in
            GeometryReader { proxy in
                ZStack(alignment: .top) {
                    Color.black
                        .ignoresSafeArea()
                    
                    LoadableView(loadable: viewStore.videoLoadable) { videoData in
                        ZStack {
                            if !viewStore.fullscreen && !viewStore.ambientMode {
                                CustomVideoPlayer(playerVM: playerVM)
                                    .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
                                    .ignoresSafeArea(.all, edges: .bottom)
                                    .clipped()
                                    .blur(radius: 20)
                                    .scaleEffect(1.2)
                                    .opacity(0.3)
                            }
                            
                            CustomVideoPlayer(playerVM: playerVM)
                                .frame(width: viewStore.fullscreen ? .infinity : proxy.size.width, height: viewStore.fullscreen ? .infinity : proxy.size.width / 16 * 9)
                                .ignoresSafeArea(.all, edges: .bottom)
                                .onTapGesture {
                                    viewStore.send(.view(.toggleUI))
                                }
                        }
                    } failedView: { error in
                        VStack {
                            Spacer()
                            
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: viewStore.fullscreen ? 46 : 32))
                                    .foregroundColor(.red)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Error")
                                        .font(viewStore.fullscreen ? .title2 : .callout)
                                        .fontWeight(.bold)
                                    
                                    Text("\((error as? VideoLoadingError)?.localizedDescription ?? "")")
                                        .font(viewStore.fullscreen ? .subheadline : .caption)
                                        .opacity(0.7)
                                }
                            }
                            .padding(viewStore.fullscreen ? 16 : 12)
                            .frame(maxWidth: viewStore.fullscreen ? 360 : 280)
                            .background(.regularMaterial)
                            .cornerRadius(20)
                            
                            Spacer()
                        }
                        .frame(width: viewStore.fullscreen ? .infinity : proxy.size.width, height: viewStore.fullscreen ? .infinity : proxy.size.width / 16 * 9)
                    } loadingView: {
                        Rectangle()
                            .fill(.black)
                            .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
                            .overlay {
                                ProgressView()
                            }
                    } pendingView: {
                        Rectangle()
                            .fill(.black)
                            .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
                            .overlay {
                                ProgressView()
                            }
                    }
                    
                    Group {
                        if viewStore.fullscreen {
                            FullscreenUI(viewStore: viewStore, playerVM: playerVM)
                        } else {
                            PortraitUI(viewStore: viewStore, playerVM: playerVM, proxy: proxy)
                        }
                    }
                }
            }
            .background {
                if !viewStore.webviewState.htmlString.isEmpty && !viewStore.webviewState.javaScript.isEmpty {
                    if viewStore.servers.count > 0 {
                        WebviewFeature.View(
                            store: self.store.scope(
                                state: \.webviewState,
                                action: Action.InternalAction.webview
                            ),
                            payload: viewStore.servers[0].list[0].url,
                            action: "video"
                        ) { result in
                            print(result)
                            viewStore.send(.view(.parseVideoResult(data: result)))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    } else {
                        WebviewFeature.View(
                            store: self.store.scope(
                                state: \.webviewState,
                                action: Action.InternalAction.webview
                            ),
                            payload: viewStore.url
                        ) { result in
                            print(result)
                            viewStore.send(.view(.parseResult(data: result)))
                            viewStore.send(.view(.resetWebviewChange))
                        }
                        .hidden()
                        .frame(maxWidth: 0, maxHeight: 0)
                    }
                }
            }
            .onChange(of: viewStore.speed) { newValue in
                playerVM.player.rate = newValue
            }
            .onChange(of: viewStore.videoLoadable) { loadable in
                
                // TODO: Refactor
                switch loadable {
                case let .loaded(data):
                    viewStore.send(.view(.setCurrentItem(data: data)))
                    if let item = viewStore.item {
                        playerVM.setCurrentItem(item)
                        playerVM.player.play()
                    } else {
                        viewStore.send(.view(.setLoadable(.failed(VideoLoadingError.dataParsingError("Couldnt create the PlayerItem")))))
                    }
                    break
                case _:
                    break
                }
            }
            .onChange(of: viewStore.quality) { newValue in
                switch viewStore.videoLoadable {
                case let .loaded(data):
                    let storeTime = playerVM.currentTime
                    
                    viewStore.send(.view(.setCurrentItem(data: data)))
                    if let item = viewStore.item {
                        playerVM.setCurrentItem(item)
                        
                        playerVM.player.seek(to: CMTime(seconds: storeTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                        
                        playerVM.player.play()
                    } else {
                        viewStore.send(.view(.setLoadable(.failed(VideoLoadingError.dataParsingError("Couldnt create the PlayerItem")))))
                    }
                    break
                case _:
                    break
                }
            }
            .onChange(of: playerVM.isInPipMode) { isPiP in
                if !isPiP {
                    viewStore.send(.view(.setPiP(false)))
                }
            }
            .onChange(of: playerVM.currentTime) { currentTime in
                // update current episode in continue watching
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    var isDirectory: ObjCBool = false
                    if !FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("Databases").path, isDirectory: &isDirectory) {
                        do {
                            try FileManager.default.createDirectory(at: documentsDirectory.appendingPathComponent("Databases"), withIntermediateDirectories: false, attributes: nil)
                            print("Created Database Directory")
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                    
                    do {
                        let dbQueue = try DatabaseQueue(path: documentsDirectory.appendingPathComponent("Databases").appendingPathComponent("chouten.sqlite").absoluteString)
                        
                        try dbQueue.write { db in
                            // Fetch the Media item using moduleID from the database
                            if var mediaItem = try Media.filter(Column("mediaUrl") == viewStore.url).fetchOne(db) {
                                // Update the current time
                                mediaItem.current = currentTime
                                
                                // Perform the update in the database
                                try mediaItem.update(db)
                            } else {
                                // If the Media item doesn't exist, you may choose to create it here
                                // For example:
                                if let infoData = viewStore.infoData {
                                    print(infoData)
                                    
                                    if infoData.mediaList.count > 0 {
                                        
                                        let item = infoData.mediaList[0].list[viewStore.index]
                                        let newMediaItem = Media(moduleID: viewStore.module?.id ?? "", image: item.image ?? infoData.poster, current: currentTime, duration: playerVM.duration ?? 1.0, title: item.title ?? "Episode \(item.number)", mediaUrl: viewStore.url, number: item.number)
                                        
                                        print(newMediaItem)
                                        
                                        try newMediaItem.insert(db)
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
            .onAppear {
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
                    let videoData = VideoData(
                        sources: [
                            Source(
                                file: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8", 
                                type: "hls",
                                quality: "auto"
                            )
                        ],
                        subtitles: [],
                        skips: [],
                        headers: nil
                    )
                    viewStore.send(.view(.setVideoData(data: videoData)))
                    viewStore.send(.view(.setInfoData(data: InfoData.sample)))
                } else {
                    viewStore.send(.view(.onAppear))
                }
            }
        }
    }
}

extension PlayerFeature.View {
    @MainActor
    func FullscreenUI(viewStore: ViewStoreOf<PlayerFeature>, playerVM: PlayerViewModel) -> some View {
        VStack {
            // Top Bar
            HStack(alignment: .top) {
                if let infoData = viewStore.infoData {
                    VStack(alignment: .leading) {
                        if let list = infoData.mediaList.first {
                            var formattedValue: String {
                                if list.list[viewStore.index].number.truncatingRemainder(dividingBy: 1) == 0 {
                                    return String(format: "%.0f", list.list[viewStore.index].number)
                                } else {
                                    return String(list.list[viewStore.index].number)
                                }
                            }
                            
                            Text("\(formattedValue): \(list.list[viewStore.index].title ?? "Episode \(formattedValue)")")
                                .fontWeight(.bold)
                        }
                        Text(infoData.titles.primary)
                            .font(.subheadline)
                            .opacity(0.7)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    
                    Text("Module Name")
                        .fontWeight(.bold)
                    
                    Text("1920x1080")
                        .font(.subheadline)
                        .opacity(0.7)
                }
            }
            
            Spacer()
            
            // Bottom Bar
            VStack {
                if let duration = playerVM.duration {
                    Seekbar(percentage: $playerVM.currentTime, buffered: .constant(0), isDragging: $playerVM.isEditingCurrentTime, total: duration)
                        .frame(maxHeight: 24)
                } else {
                    Seekbar(percentage: .constant(0), buffered: .constant(0), isDragging: .constant(false), total: 400)
                        .frame(maxHeight: 24)
                }
                
                HStack {
                    if let duration = playerVM.duration {
                        let currentTimeString = secondsToMinutesSeconds(Int(playerVM.currentTime))
                        let durationString = secondsToMinutesSeconds(Int(duration))
                        Text("\(currentTimeString)/\(durationString)")
                    } else {
                        Text("--:--/--:--")
                    }
                    
                    Spacer()
                    
                    Button {
                        viewStore.send(.view(.setShowMenu(true)))
                    } label: {
                        Image(systemName: "gear")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        viewStore.send(.view(.setFullscreen(false)))
                    } label: {
                        Image(systemName: "arrow.down.right.and.arrow.up.left")
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            Color.black
                .opacity(viewStore.showMenu ? 0.3 : 0.0)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .allowsHitTesting(viewStore.showMenu)
                .onTapGesture {
                    viewStore.send(.view(.setShowMenu(false)))
                }
                .animation(.spring(response: 0.3), value: viewStore.showMenu)
        }
        .overlay(alignment: .bottomTrailing) {
            if viewStore.showMenu {
                PlayerMenu(
                    selectedQuality: viewStore.binding(
                        get: \.quality,
                        send: { PlayerFeature.Action.view(.setQuality(value: $0)) }
                    ),
                    selectedServer: viewStore.binding(
                        get: \.server,
                        send: { PlayerFeature.Action.view(.setServer(value: $0)) }
                    ),
                    selectedSpeed: viewStore.binding(
                        get: \.speed,
                        send: { PlayerFeature.Action.view(.setSpeed(value: $0)) }
                    ),
                    qualities: Array(viewStore.qualities.keys),
                    servers: [],
                    speeds: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
                )
                .padding(.bottom, 30)
                .padding(.trailing, -16)
                .alignmentGuide(HorizontalAlignment.trailing) { d in
                    d[HorizontalAlignment.trailing]
                }
                .alignmentGuide(VerticalAlignment.top) { d in
                    d[VerticalAlignment.bottom]
                }
            }
        }
        .background {
            if case .failed(_) =  viewStore.videoLoadable {
                // TODO: Fix to not need an else
            } else {
                HStack(spacing: 120) {
                    ZStack {
                        Text("10")
                            .font(.system(size: 10, weight: .bold))
                            .offset(y: 2)
                        
                        Image(systemName: "gobackward")
                            .font(.system(size: 32))
                        
                        Text("-10")
                            .font(.system(size: 18, weight: .semibold))
                            .offset(x: 0, y: 2)
                            .opacity(0.0)
                    }
                    .contentShape(Rectangle())
                    .opacity(0.7)
                    
                    if case .loaded(_) =  viewStore.videoLoadable {
                        Button {
                            // play/pause
                            if playerVM.isPlaying {
                                playerVM.player.pause()
                            } else {
                                playerVM.player.play()
                            }
                        } label: {
                            Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    
                    ZStack {
                        Text("10")
                            .font(.system(size: 10, weight: .bold))
                            .offset(y: 2)
                        
                        Image(systemName: "goforward")
                            .font(.system(size: 32))
                        
                        Text("+10")
                            .font(.system(size: 18, weight: .semibold))
                            .offset(x: 0, y: 2)
                            .opacity(0.0)
                    }
                    .contentShape(Rectangle())
                    .opacity(0.7)
                }
            }
        }
        .background {
            if case .failed(_) =  viewStore.videoLoadable {
                // TODO: Fix to not need an else
            } else {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.7), location: 0.0),
                        .init(color: .black.opacity(0.4), location: 0.3),
                        .init(color: .black.opacity(0.4), location: 0.7),
                        .init(color: .black.opacity(0.7), location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .onTapGesture {
                    viewStore.send(.view(.toggleUI))
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded{ value in
                    if value.translation.height > 60 {
                        viewStore.send(.view(.setFullscreen(false)))
                    }
                }
        )
        .opacity(viewStore.showUI ? 1.0 : 0.0)
        .animation(.easeInOut, value: viewStore.showUI)
    }
}

extension PlayerFeature.View {
    @MainActor
    func PortraitUI(
        viewStore: ViewStoreOf<PlayerFeature>,
        playerVM: PlayerViewModel,
        proxy: GeometryProxy
    ) -> some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        playerVM.player.pause()
                        playerVM.player.replaceCurrentItem(with: nil)
                        
                        viewStore.send(.view(.navigateBack))
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                            .padding(8)
                            .background {
                                Circle()
                                    .fill(.indigo)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                    }
                    
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("cc")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 1)
                            .padding(.bottom, 2)
                            .padding(.horizontal, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.white)
                            }
                    }
                    
                    Button {
                        playerVM.isInPipMode = true
                        viewStore.send(.view(.setPiP(true)))
                    } label: {
                        Image(systemName: playerVM.isInPipMode ? "pip.exit" : "pip.enter")
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                    }
                    
                    Button {
                        if let playerItem = viewStore.item, let module = viewStore.module {
                            print("capturing frame")
                            captureFrame(of: playerItem, at: playerVM.player.currentTime(), module: module, url: viewStore.url)
                        } else {
                            print("no player item found")
                        }
                    } label: {
                        Image(systemName: "gear")
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                HStack {
                    if let duration = playerVM.duration {
                        let durationString = secondsToMinutesSeconds(Int(duration))
                        let currentTimeString =  secondsToMinutesSeconds(Int(playerVM.currentTime))
                        
                        Text("\(currentTimeString)/\(durationString)")
                            .font(.caption)
                    } else {
                        Text("--:--/--:--")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewStore.send(.view(.setFullscreen(true)))
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .contentShape(Rectangle())
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, -8)
                
                if let duration = playerVM.duration {
                    Seekbar(percentage: $playerVM.currentTime, buffered: .constant(0), isDragging: $playerVM.isEditingCurrentTime, total: duration)
                        .frame(maxHeight: 24)
                } else {
                    Seekbar(percentage: .constant(0), buffered: .constant(0), isDragging: .constant(false), total: 400)
                        .frame(maxHeight: 24)
                }
            }
            .padding()
            .background {
                if case .failed(_) =  viewStore.videoLoadable {
                    // TODO: Fix to not need an else
                } else {
                    if viewStore.videoLoadable != .loading {
                        Button {
                            // play/pause
                            if playerVM.isPlaying {
                                playerVM.player.pause()
                            } else {
                                playerVM.player.play()
                            }
                        } label: {
                            Image(systemName: playerVM.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 30)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .background {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.7), location: 0.0),
                        .init(color: .black.opacity(0.2), location: 0.3),
                        .init(color: .black.opacity(0.2), location: 0.7),
                        .init(color: .black.opacity(0.7), location: 1.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .onTapGesture {
                    viewStore.send(.view(.toggleUI))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded{ value in
                        if value.translation.height > 60 {
                            // PiP
                            playerVM.isInPipMode = true
                            viewStore.send(.view(.setPiP(true)))
                        } else if value.translation.height < -60 {
                            // fullscreen
                            viewStore.send(.view(.setFullscreen(true)))
                        }
                    }
            )
            .opacity(viewStore.showUI ? 1.0 : 0.0)
            .animation(.easeInOut, value: viewStore.showUI)
            
            if let infoData = viewStore.infoData {
                ScrollView {
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
                        
                        if infoData.mediaList.count > 0 {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(infoData.mediaList[0].title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .padding(6)
                                        .background {
                                            Circle()
                                                .fill(.regularMaterial)
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
                        }
                        // Episode List
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview("Player") {
    PlayerFeature.View(
        store: .init(
            initialState: .init(),
            reducer: { PlayerFeature() }
        )
    )
}
