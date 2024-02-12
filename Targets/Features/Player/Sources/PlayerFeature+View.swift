//
//  PlayerFeature+View.swift
//
//
//  Created by Inumaki on 16.10.23.
//
// swiftlint:disable identifier_name

import Architecture
import AVKit
import Combine
import ComposableArchitecture
import GRDB
import Kingfisher
import SharedModels
import SwiftUI
import ViewComponents
import Webview

// MARK: - Seekbar

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
                * CGFloat(buffered / total)
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
                * CGFloat(percentage / total)
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
                percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
                isDragging = false
                barHeight = 6
              }
              .onChanged { value in
                isDragging = true
                barHeight = 10
                // TODO: - maybe use other logic here
                percentage = min(max(0, Double(value.location.x / geometry.size.width * total)), total)
              }
          )
      }
      .animation(.spring(response: 0.3), value: isDragging)
    }
  }
}

// MARK: - SeekbarBridge

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

// MARK: - PlayerView

class PlayerView: UIView {
  // Override the property to make AVPlayerLayer the view's backing layer.
  override static var layerClass: AnyClass { AVPlayerLayer.self }

  // The associated player object.
  var player: AVPlayer? {
    get { playerLayer.player }
    set { playerLayer.player = newValue }
  }

  var playerLayer: AVPlayerLayer { unsafeDowncast(layer, to: AVPlayerLayer.self) }
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

// MARK: - PlayerViewModel

final class PlayerViewModel: ObservableObject {
  let player = AVPlayer()
  @Published var isInPipMode = false
  @Published var isPlaying = false

  @Published var isEditingCurrentTime = false
  @Published var currentTime: Double = .zero
  @Published var duration: Double?

  private var subscriptions: Set<AnyCancellable> = []
  private var timeObserver: Any?

  deinit {
    if let timeObserver {
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
      .filter { $0 == false }
      .sink(receiveValue: { [weak self] _ in
        guard let self else { return }
        player.seek(to: CMTime(seconds: currentTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        if player.rate != 0 {
          player.play()
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

    self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { [weak self] time in
      guard let self else { return }
      if isEditingCurrentTime == false {
        self.currentTime = time.seconds
      }
    }
  }

  func setCurrentItem(_ item: AVPlayerItem) {
    currentTime = .zero
    duration = nil
    player.replaceCurrentItem(with: item)

    item.publisher(for: \.status)
      .filter { $0 == .readyToPlay }
      .sink(receiveValue: { [weak self] _ in
        self?.duration = item.asset.duration.seconds
      })
      .store(in: &subscriptions)
  }
}

// MARK: - CustomVideoPlayer

struct CustomVideoPlayer: UIViewRepresentable {
  @ObservedObject var playerVM: PlayerViewModel

  func makeUIView(context: Context) -> PlayerView {
    let view = PlayerView()
    view.player = playerVM.player
    context.coordinator.setController(view.playerLayer)
    return view
  }

  func updateUIView(_: PlayerView, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
    private let parent: CustomVideoPlayer
    private var controller: AVPictureInPictureController?
    private var cancellable: AnyCancellable?
    private var subtitlesHidden = false

    init(_ parent: CustomVideoPlayer) {
      self.parent = parent
      super.init()

      self.cancellable = parent.playerVM.$isInPipMode
        .sink { [weak self] in
          guard let self,
                let controller else { return }
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

    func pictureInPictureControllerDidStartPictureInPicture(_: AVPictureInPictureController) {
      parent.playerVM.isInPipMode = true
    }

    func pictureInPictureControllerWillStopPictureInPicture(_: AVPictureInPictureController) {
      parent.playerVM.isInPipMode = false
    }
  }
}

extension PlayerFeature.View {
  @MainActor public var body: some View {
    WithPerceptionTracking {
      GeometryReader { proxy in
        ZStack(alignment: .top) {
          Color.black
            .ignoresSafeArea()

          LoadableView(loadable: store.videoLoadable) { _ in
            ZStack {
              if !store.fullscreen, !store.ambientMode {
                CustomVideoPlayer(playerVM: playerVM)
                  .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
                  .ignoresSafeArea(.all, edges: .bottom)
                  .clipped()
                  .blur(radius: 20)
                  .scaleEffect(1.2)
                  .opacity(0.3)
              }

              CustomVideoPlayer(playerVM: playerVM)
                .frame(width: store.fullscreen ? .infinity : proxy.size.width, height: store.fullscreen ? .infinity : proxy.size.width / 16 * 9)
                .ignoresSafeArea(.all, edges: .bottom)
                .onTapGesture {
                  store.send(.view(.toggleUI))
                }
            }
          } failedView: { error in
            VStack {
              Spacer()

              HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: store.fullscreen ? 46 : 32))
                  .foregroundColor(.red)

                VStack(alignment: .leading, spacing: 8) {
                  Text("Error")
                    .font(store.fullscreen ? .title2 : .callout)
                    .fontWeight(.bold)

                  Text("\((error as? VideoLoadingError)?.localizedDescription ?? "")")
                    .font(store.fullscreen ? .subheadline : .caption)
                    .opacity(0.7)
                }
              }
              .padding(store.fullscreen ? 16 : 12)
              .frame(maxWidth: store.fullscreen ? 360 : 280)
              .background(.regularMaterial)
              .cornerRadius(20)

              Spacer()
            }
            .frame(width: store.fullscreen ? .infinity : proxy.size.width, height: store.fullscreen ? .infinity : proxy.size.width / 16 * 9)
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
            if store.fullscreen {
              FullscreenUI(playerVM: playerVM)
            } else {
              PortraitUI(playerVM: playerVM, proxy: proxy)
            }
          }
        }
      }
      .background {
        if !store.webviewState.htmlString.isEmpty, !store.webviewState.javaScript.isEmpty {
          if !store.servers.isEmpty {
            WebviewFeature.View(
              store: self.store.scope(
                state: \.webviewState,
                action: \.internal.webview
              ),
              payload: store.servers[0].list[0].url,
              action: "video"
            ) { result in
              print(result)
              store.send(.view(.parseVideoResult(data: result)))
            }
            .hidden()
            .frame(maxWidth: 0, maxHeight: 0)
          } else {
            WebviewFeature.View(
              store: self.store.scope(
                state: \.webviewState,
                action: \.internal.webview
              ),
              payload: store.url
            ) { result in
              print(result)
              store.send(.view(.parseResult(data: result)))
              store.send(.view(.resetWebviewChange))
            }
            .hidden()
            .frame(maxWidth: 0, maxHeight: 0)
          }
        }
      }
      .onChange(of: store.speed) { newValue in
        playerVM.player.rate = newValue
      }
      .onChange(of: store.videoLoadable) { loadable in

        // TODO: Refactor
        switch loadable {
        case let .loaded(data):
          store.send(.view(.setCurrentItem(data: data)))
          if let item = store.item {
            playerVM.setCurrentItem(item)
            playerVM.player.play()
          } else {
            store.send(.view(.setLoadable(.failed(VideoLoadingError.dataParsingError("Couldnt create the PlayerItem")))))
          }
        case _:
          break
        }
      }
      .onChange(of: store.quality) { _ in
        switch store.videoLoadable {
        case let .loaded(data):
          let storeTime = playerVM.currentTime

          store.send(.view(.setCurrentItem(data: data)))
          if let item = store.item {
            playerVM.setCurrentItem(item)

            playerVM.player.seek(to: CMTime(seconds: storeTime, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)

            playerVM.player.play()
          } else {
            store.send(.view(.setLoadable(.failed(VideoLoadingError.dataParsingError("Couldnt create the PlayerItem")))))
          }
        case _:
          break
        }
      }
      .onChange(of: playerVM.isInPipMode) { isPiP in
        if !isPiP {
          store.send(.view(.setPiP(false)))
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
              if var mediaItem = try Media.filter(Column("mediaUrl") == store.url).fetchOne(db) {
                // Update the current time
                mediaItem.current = currentTime

                // Perform the update in the database
                try mediaItem.update(db)
              } else {
                // If the Media item doesn't exist, you may choose to create it here
                // For example:
                if let infoData = store.infoData {
                  print(infoData)

                  if let item = infoData.mediaList.first?.list[store.index], let module = store.module {
                    let newMediaItem = Media(
                      moduleID: module.id,
                      image: item.image ?? infoData.poster,
                      current: currentTime,
                      duration: playerVM.duration ?? 1.0,
                      title: item.title ?? "Episode \(item.number)",
                      mediaUrl: store.url,
                      number: item.number
                    )

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
          store.send(.view(.setVideoData(data: videoData)))
          store.send(.view(.setInfoData(data: InfoData.sample)))
        } else {
          store.send(.view(.onAppear))
        }
      }
    }
  }
}

extension PlayerFeature.View {
  @MainActor
  func FullscreenUI(playerVM: PlayerViewModel) -> some View {
    VStack {
      // Top Bar
      HStack(alignment: .top) {
        if let infoData = store.infoData {
          VStack(alignment: .leading) {
            if let list = infoData.mediaList.first {
//              var formattedValue: String {
//                if list.list[store.index].number.truncatingRemainder(dividingBy: 1) == 0 {
//                  String(format: "%.0f", list.list[store.index].number)
//                } else {
//                  String(list.list[store.index].number)
//                }
//              }
//
//              Text("\(formattedValue): \(list.list[store.index].title ?? "Episode \(formattedValue)")")
//                .fontWeight(.bold)
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
            store.send(.view(.setShowMenu(true)))
          } label: {
            Image(systemName: "gear")
              .font(.title3)
              .foregroundColor(.white)
          }

          Button {
            store.send(.view(.setFullscreen(false)))
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
        .opacity(store.showMenu ? 0.3 : 0.0)
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .allowsHitTesting(store.showMenu)
        .onTapGesture {
          store.send(.view(.setShowMenu(false)))
        }
        .animation(.spring(response: 0.3), value: store.showMenu)
    }
    .overlay(alignment: .bottomTrailing) {
      if store.showMenu {
        PlayerMenu(
          selectedQuality: $store.quality.sending(\.view.setQuality),
          selectedServer: $store.server.sending(\.view.setServer),
          selectedSpeed: $store.speed.sending(\.view.setSpeed),
          qualities: Array(store.qualities.keys),
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
      if case .failed = store.videoLoadable {
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

          if case .loaded = store.videoLoadable {
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
      if case .failed = store.videoLoadable {
        // TODO: Fix to not need an else
      } else {
        LinearGradient(
          stops: [
            .init(color: .black.opacity(0.7), location: 0.0),
            .init(color: .black.opacity(0.4), location: 0.3),
            .init(color: .black.opacity(0.4), location: 0.7),
            .init(color: .black.opacity(0.7), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .ignoresSafeArea()
        .onTapGesture {
          store.send(.view(.toggleUI))
        }
      }
    }
    .contentShape(Rectangle())
    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.height > 60 {
            store.send(.view(.setFullscreen(false)))
          }
        }
    )
    .opacity(store.showUI ? 1.0 : 0.0)
    .animation(.easeInOut, value: store.showUI)
  }
}

extension PlayerFeature.View {
  @MainActor
  func PortraitUI(
    playerVM: PlayerViewModel,
    proxy: GeometryProxy
  ) -> some View {
    VStack {
      VStack(alignment: .leading) {
        HStack {
          Button {
            playerVM.player.pause()
            playerVM.player.replaceCurrentItem(with: nil)

            store.send(.view(.navigateBack))
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

          Button {} label: {
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
            store.send(.view(.setPiP(true)))
          } label: {
            Image(systemName: playerVM.isInPipMode ? "pip.exit" : "pip.enter")
              .contentShape(Rectangle())
              .foregroundColor(.white)
          }

          Button {
            if let playerItem = store.item, let module = store.module {
              print("capturing frame")
              captureFrame(of: playerItem, at: playerVM.player.currentTime(), module: module, url: store.url)
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
            let currentTimeString = secondsToMinutesSeconds(Int(playerVM.currentTime))

            Text("\(currentTimeString)/\(durationString)")
              .font(.caption)
          } else {
            Text("--:--/--:--")
              .font(.caption)
          }

          Spacer()

          Button {
            store.send(.view(.setFullscreen(true)))
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
        if case .failed = store.videoLoadable {
          // TODO: Fix to not need an else
        } else {
          if store.videoLoadable != .loading {
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
            .init(color: .black.opacity(0.7), location: 1.0)
          ],
          startPoint: .top,
          endPoint: .bottom
        )
        .onTapGesture {
          store.send(.view(.toggleUI))
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.width / 16 * 9)
      .contentShape(Rectangle())
      .gesture(
        DragGesture()
          .onEnded { value in
            if value.translation.height > 60 {
              // PiP
              playerVM.isInPipMode = true
              store.send(.view(.setPiP(true)))
            } else if value.translation.height < -60 {
              // fullscreen
              store.send(.view(.setFullscreen(true)))
            }
          }
      )
      .opacity(store.showUI ? 1.0 : 0.0)
      .animation(.easeInOut, value: store.showUI)

      if let infoData = store.infoData {
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

            if !infoData.mediaList.isEmpty {
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
