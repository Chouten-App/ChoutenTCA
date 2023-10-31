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
                    .foregroundColor(.white.opacity(0.4)).frame(height: barHeight, alignment: .bottom).cornerRadius(12)
                
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
            .cornerRadius(400)
            .frame(maxHeight: .infinity, alignment: .center)
            .clipped(antialiased: true)
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
                            if !viewStore.fullscreen {
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
                        }
                    } failedView: { error in
                        Text("\(error.localizedDescription)")
                            .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
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
                    
                    if viewStore.fullscreen {
                        VStack {
                            // Top Bar
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("1: Episode Title")
                                        .fontWeight(.bold)
                                    Text("Primary Title")
                                        .font(.subheadline)
                                        .opacity(0.7)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    
                                    
                                    Text("Module Name")
                                        .fontWeight(.bold)
                                    
                                    Text("\(viewStore.fullscreen ? "Landscape" : "Portrait")")
                                        .font(.subheadline)
                                        .opacity(0.7)
                                    
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
                                }
                            }
                        }
                        .padding(.top)
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
                                    )
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
                            HStack(spacing: 60) {
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
                        .background {
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
                            .allowsHitTesting(false)
                        }
                    } else {
                        VStack {
                            VStack {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        Image(systemName: "gear")
                                            .contentShape(Rectangle())
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Spacer()
                                
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
                            .background {
                                LinearGradient(
                                    stops: [
                                        .init(color: .black.opacity(0.7), location: 0.0),
                                        .init(color: .black.opacity(0.0), location: 0.3),
                                        .init(color: .black.opacity(0.0), location: 0.7),
                                        .init(color: .black.opacity(0.7), location: 1.0),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
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
                switch loadable {
                case let .loaded(data):
                    let dict = Dictionary(uniqueKeysWithValues: data.sources.map { ($0.quality, $0.file) })
                    viewStore.send(.view(.setQualityDict(dict)))
                    
                    //let item = AVPlayerItem(url: URL(string: viewStore.qualities[viewStore.quality] ?? "")!)
                    
                    var subs: [VideoCompositionItem.SubtitleINTERNAL] = []
                    
                    if !data.subtitles.isEmpty {
                        let sub = data.subtitles.filter({ ($0.language ?? "").contains("English") })[0]
                        
                        subs.append(VideoCompositionItem.SubtitleINTERNAL(
                            name: sub.language ?? "N/A",
                            default: true,
                            autoselect: true,
                            link: URL(string: sub.url)!
                        ))
                    }
                    
                    if let url = URL(string: viewStore.qualities[viewStore.quality] ?? "") {
                        let videoCompItem = VideoCompositionItem(
                            link: url,
                            headers: data.headers ?? [:],
                            subtitles: subs
                        )
                        
                        let item = PlayerItem(videoCompItem)
                        
                        playerVM.setCurrentItem(item)
                        playerVM.player.play()
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
                    
                    var subs: [VideoCompositionItem.SubtitleINTERNAL] = []
                    
                    if !data.subtitles.isEmpty {
                        let sub = data.subtitles.filter({ ($0.language ?? "").contains("English") })[0]
                        
                        subs.append(VideoCompositionItem.SubtitleINTERNAL(
                            name: sub.language ?? "N/A",
                            default: true,
                            autoselect: true,
                            link: URL(string: sub.url)!
                        ))
                    }
                    
                    let videoCompItem = VideoCompositionItem(
                        link: URL(string: viewStore.qualities[newValue] ?? "")!,
                        headers: data.headers ?? [:],
                        subtitles: subs
                    )
                    
                    let item = PlayerItem(videoCompItem)
                    
                    playerVM.setCurrentItem(item)
                    
                    playerVM.player.seek(to: CMTime(seconds: storeTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                    
                    playerVM.player.play()
                    break
                case _:
                    break
                }
            }
            .onChange(of: playerVM.isInPipMode) { newValue in
                if !newValue {
                    viewStore.send(.view(.setPiP(false)))
                }
            }
            .onAppear {
                viewStore.send(.view(.onAppear))
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
