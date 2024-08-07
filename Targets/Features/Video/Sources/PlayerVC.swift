import AVKit
import ComposableArchitecture
import SharedModels
import UIKit

// swiftlint:disable type_body_length
public class PlayerVC: UIViewController {
    var store: Store<VideoFeature.State, VideoFeature.Action>

    var data: MediaItem
    let info: InfoData
    var index: Int
    var selectedMediaListIndex: Int = 0

    let playerVM = PlayerViewModel()
    let subtitleRenderer = SubtitleRenderer()
    let controls = PlayerControlsController()
    lazy var customVideoPlayer = CustomVideoPlayer(playerVM: playerVM)

    private var timeObserver: Any?
    private var blackOverlayView: UIView?

    var showUI = true

    var singleTapTimer: Timer?
    let tapInterval = 0.2  // Adjust this interval to suit your needs

    var nextEpisodeTimer: Timer?
    var nextEpisodeDisplayLink: CADisplayLink?
    var nextEpisodeStartTime: Date?
    var nextEpisodeDuration: TimeInterval = 5.0 // 5 seconds
    var isShowingNextEpisodeButton = false

    private var shouldForceLandscape: Bool = false {
        didSet {
            if shouldForceLandscape {
                applyGeometryUpdate(interfaceOrientation: .landscapeRight)
            } else {
                applyGeometryUpdate(interfaceOrientation: .portrait)
            }
        }
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        shouldForceLandscape ? [.landscape, .landscapeLeft, .landscapeRight] : [.portrait, .landscape, .landscapeLeft, .landscapeRight]
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        shouldForceLandscape ? .landscapeRight : .portrait
    }

    override public var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    var mediaSelector = MediaSelector()

    public init(data: MediaItem, info: InfoData, index: Int) {
        self.data = data
        self.info = info
        self.index = index
        store = .init(
            initialState: .init(),
            reducer: { VideoFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear(data.url)))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure() {
        view.backgroundColor = .black

        customVideoPlayer.translatesAutoresizingMaskIntoConstraints = false
        controls.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(customVideoPlayer)
        view.addSubview(subtitleRenderer)
        addChild(controls)
        view.addSubview(controls.view)
        controls.didMove(toParent: self)

        mediaSelector = MediaSelector(mediaList: info.mediaList, fallbackImageUrl: info.poster)
        view.addSubview(mediaSelector)
        mediaSelector.alpha = 0.0

        mediaSelector.closeButton.onTap = {
            UIView.animate(withDuration: 0.2) {
                self.mediaSelector.alpha = 0.0
            }
        }

        controls.delegate = self
        customVideoPlayer.pictureInPictureController?.delegate = self

        // Set data of UI
        controls.subtitleLabel.text = data.title ?? "Episode \(data.number)"
        controls.titleLabel.text = info.titles.primary

        NSLayoutConstraint.activate([
            customVideoPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customVideoPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customVideoPlayer.topAnchor.constraint(equalTo: view.topAnchor),
            customVideoPlayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            subtitleRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subtitleRenderer.topAnchor.constraint(equalTo: view.topAnchor),
            subtitleRenderer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            controls.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controls.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controls.view.topAnchor.constraint(equalTo: view.topAnchor),
            controls.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mediaSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mediaSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mediaSelector.topAnchor.constraint(equalTo: view.topAnchor),
            mediaSelector.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.5
        view.addGestureRecognizer(longPressRecognizer)

        observe { [weak self] in
            guard let self = self else { return }

            if let serverLists = store.serverLists,
               self.controls.servers == nil {
                self.controls.selectedServerIndex = 0
                self.controls.servers = serverLists
                self.controls.updateData()
            }
            switch store.status {
            case .loading:
                controls.hidePlayButton()
            case .success:
                if let url = URL(string: store.videoData?.streams.first?.file ?? "") {
                    // load subtitles
                    if let englishUrl = store.videoData?.subtitles.first(where: { $0.language.lowercased() == "english" })?.url,
                       let subtitleUrl = URL(string: englishUrl) {
                        subtitleRenderer.loadSubtitles(from: subtitleUrl)
                    }

                    let asset = AVAsset(url: url)
                    let item = AVPlayerItem(asset: asset)
                    playerVM.setCurrentItem(item)
                    controls.showPlayButton()

                    controls.duration = item.asset.duration.seconds
                    controls.durationLabel.text = self.formatTime(item.asset.duration.seconds)

                    timeObserver = playerVM.player
                        .addPeriodicTimeObserver(
                            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                            queue: .main
                        ) { [weak self] time in
                            guard let self = self else { return }

                            // update subtitles
                            self.subtitleRenderer.updateSubtitles(for: time)

                            self.controls.currentTimeLabel.text = self.formatTime(time.seconds)
                            if let duration = playerVM.duration {
                                self.view.layoutIfNeeded()
                                UIView.animate(withDuration: 0.1) {
                                    self.controls.progressBar.updateProgress(time.seconds / duration)
                                    self.view.layoutIfNeeded()
                                }
                            }

                            if (time.seconds / item.asset.duration.seconds >= 0.8) && !isShowingNextEpisodeButton {
                                isShowingNextEpisodeButton = true
                                showNextEpisodeButton()
                            }
                        }
                    self.controls.data = store.videoData
                    self.controls.selectedSourceIndex = 0
                    self.controls.updateData()
                }
            default:
                break
            }
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBlackOverlay()

        shouldForceLandscape = true
        applyGeometryUpdate(interfaceOrientation: .landscapeRight)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideBlackOverlay()
            self.configure()
        }
    }

    func orientationMask(for orientation: UIInterfaceOrientation) -> UIInterfaceOrientationMask {
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown:
            return []
        @unknown default:
            return []
        }
    }

    private func applyGeometryUpdate(interfaceOrientation: UIInterfaceOrientation) {
        if #available(iOS 16.0, *) {
            if let windowScene = view.window?.windowScene {
                // Update the supported orientations before requesting geometry update
                self.setNeedsUpdateOfSupportedInterfaceOrientations()

                // Convert the desired orientation to UIInterfaceOrientationMask
                let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientationMask(for: interfaceOrientation))

                windowScene.requestGeometryUpdate(geometryPreferences) { error in
                    print("Error requesting geometry update: \(error.localizedDescription)")
                }
            }
        } else {
            UIDevice.current.setValue(interfaceOrientation.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        }
    }

//    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        showBlackOverlay()
//        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
//            self?.hideBlackOverlay()
//        }
//    }

    private func showBlackOverlay() {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = .black
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        blackOverlayView = overlayView
    }

    private func hideBlackOverlay() {
        blackOverlayView?.removeFromSuperview()
        blackOverlayView = nil
    }

    func showNextEpisodeButton() {
        controls.nextEpisodeProgress.transform = CGAffineTransform(translationX: -controls.nextEpisodeButton.frame.width, y: 0)
        // Show next episode button with animation
        controls.hideUI(exceptBlack: true)
        UIView.animate(withDuration: 0.2, delay: 0.2) {
            self.controls.nextEpisodeButton.alpha = 1.0
        } completion: { _ in
            // Start a 5-second timer and a display link for progress updates
            self.nextEpisodeStartTime = Date()
            self.nextEpisodeTimer = Timer.scheduledTimer(
                timeInterval: self.nextEpisodeDuration,
                target: self,
                selector: #selector(self.nextEpisode),
                userInfo: nil,
                repeats: false
            )
            self.nextEpisodeDisplayLink = CADisplayLink(target: self, selector: #selector(self.updateProgress))
            self.nextEpisodeDisplayLink?.add(to: .main, forMode: .default)
        }
    }

    @objc func updateProgress() {
        guard let startTime = self.nextEpisodeStartTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let progress = elapsed / self.nextEpisodeDuration

        DispatchQueue.main.async {
            self.controls.nextEpisodeProgress.transform = CGAffineTransform(
                translationX: -self.controls.nextEpisodeButton.frame.width +
                                (self.controls.nextEpisodeButton.frame.width * progress),
                y: 0
            )
        }

        // Animate progress (e.g., update a progress bar)
        // self.progressBar.setProgress(Float(progress), animated: true)

        if progress >= 1.0 {
            // Invalidate the display link once the progress is complete
            self.nextEpisodeDisplayLink?.invalidate()
            self.nextEpisodeDisplayLink = nil
        }
    }

    @objc func nextEpisode() {
        playerVM.player.replaceCurrentItem(with: nil)
        index += 1
        if let list = info.mediaList.first?.pagination.first?.items,
        list.count > index {
            let mediaItem = list[index]
            data = mediaItem
            DispatchQueue.main.async {
                self.controls.subtitleLabel.text = mediaItem.title ?? "Episode \(mediaItem.number.removeTrailingZeros())"
            }
            store.send(.view(.onAppear(data.url)))
        }

        isShowingNextEpisodeButton = false
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let timer = singleTapTimer {
            timer.invalidate()
            singleTapTimer = nil
            handleDoubleTap(sender)
        } else {
            singleTapTimer = Timer.scheduledTimer(
                timeInterval: tapInterval,
                target: self,
                selector: #selector(handleSingleTap(_:)),
                userInfo: sender,
                repeats: false
            )
        }
    }

    @objc func handleSingleTap(_ timer: Timer) {
        guard let sender = timer.userInfo as? UITapGestureRecognizer else { return }
        let location = sender.location(in: sender.view)
        let xPosition = location.x

        // Perform additional actions with xPosition if needed
        showUI.toggle()

        if isShowingNextEpisodeButton {
            nextEpisodeTimer?.invalidate()
            self.nextEpisodeDisplayLink?.invalidate()
            self.nextEpisodeDisplayLink = nil
            UIView.animate(withDuration: 0.2) {
                self.controls.nextEpisodeButton.alpha = 0.0
            } completion: { _ in
                self.showUI = false
                self.controls.hideUI()

                self.singleTapTimer = nil
            }
            return
        }

        if showUI {
            controls.showUI()
        } else {
            controls.hideUI()
        }

        singleTapTimer = nil
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        let xPosition = location.x

        let thirdOfScreenWidth = UIScreen.main.bounds.width / 3

        if xPosition <= thirdOfScreenWidth {
            // seek back 10 seconds
            UIView.animate(withDuration: 0.1) {
                self.controls.backwardButton.alpha = 1.0
            } completion: { _ in
                self.playerVM.isEditingCurrentTime = true
                self.playerVM.currentTime -= 10
                self.playerVM.isEditingCurrentTime = false
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
                    // rotate icon
                    self.controls.backwardIcon.transform = CGAffineTransform(rotationAngle: -(20 * CGFloat.pi / 180))

                    // translate text
                    self.controls.backwardText.transform = CGAffineTransform(translationX: -32, y: 0)
                } completion: { _ in
                    // reverse
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
                        self.controls.backwardButton.alpha = 0.0
                    } completion: { _ in
                        // rotate icon
                        self.controls.backwardIcon.transform = .identity

                        // translate text
                        self.controls.backwardText.transform = .identity
                    }
                }
            }
        } else if xPosition >= 2 * thirdOfScreenWidth {
            // seek forward 10 seconds
            UIView.animate(withDuration: 0.1) {
                self.controls.forwardButton.alpha = 1.0
            } completion: { _ in
                self.playerVM.isEditingCurrentTime = true
                self.playerVM.currentTime += 10
                self.playerVM.isEditingCurrentTime = false
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
                    // rotate icon
                    self.controls.forwardIcon.transform = CGAffineTransform(rotationAngle: 20 * CGFloat.pi / 180)

                    // translate text
                    self.controls.forwardText.transform = CGAffineTransform(translationX: 32, y: 0)
                } completion: { _ in
                    // reverse
                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
                        self.controls.forwardButton.alpha = 0.0
                    } completion: { _ in
                        // rotate icon
                        self.controls.forwardIcon.transform = .identity

                        // translate text
                        self.controls.forwardText.transform = .identity
                    }
                }
            }
        }

        // Perform additional actions with xPosition if needed
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: sender.view)
        let xPosition = location.x

        switch sender.state {
        case .began:
            playerVM.player.rate = 2.0
            UIView.animate(withDuration: 0.2) {
                self.controls.fastForwardWrapper.alpha = 1.0
            }
        case .changed:
            break
        case .ended, .cancelled:
            playerVM.player.rate = 1.0
            UIView.animate(withDuration: 0.2) {
                self.controls.fastForwardWrapper.alpha = 0.0
            }
        default:
            break
        }
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "frame" {
            adjustCustomViewForPiP()
        }
    }

    private func adjustCustomViewForPiP() {
        guard let window = UIApplication.shared.windows.first else { return }

        // Get the current size of the window (PiP window size)
        let pipWindowSize = window.frame.size

        // pip seems to have padding of 11 px (checked on iphone 12)
        let maxPipWindowWidth = UIScreen.main.bounds.height - 22
        let multiplier = pipWindowSize.width / maxPipWindowWidth

        subtitleRenderer.fontSize = 8.0 * multiplier
        subtitleRenderer.updateLabelSizes()
        subtitleRenderer.updateBottomPadding(multiplier: multiplier)
    }

    deinit {
        if let observer = timeObserver {
            playerVM.player.removeTimeObserver(observer)
        }
    }
}
// swiftlint:enable type_body_length

extension PlayerVC: AVPictureInPictureControllerDelegate {
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        playerVM.isInPipMode = true
    }

    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        playerVM.isInPipMode = false
        subtitleRenderer.isPiP = false
        subtitleRenderer.fontSize = 16.0
        subtitleRenderer.stack.spacing = 12.0
        subtitleRenderer.updateLabelSizes()
        subtitleRenderer.updateBottomPadding(multiplier: 1.0)
        if let window = UIApplication.shared.windows.first {
            window.removeObserver(self, forKeyPath: "frame")
        }

        view.addSubview(subtitleRenderer)
        view.bringSubviewToFront(controls.view)
        subtitleRenderer.updateLabelSizes()

        NSLayoutConstraint.activate([
            subtitleRenderer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleRenderer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subtitleRenderer.topAnchor.constraint(equalTo: view.topAnchor),
            subtitleRenderer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if let window = UIApplication.shared.windows.first {
            window.addSubview(subtitleRenderer)
            window.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)

            subtitleRenderer.isPiP = true
            subtitleRenderer.stack.spacing = 6.0
            subtitleRenderer.updateLabelSizes()

            NSLayoutConstraint.activate([
                subtitleRenderer.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                subtitleRenderer.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                subtitleRenderer.topAnchor.constraint(equalTo: window.topAnchor),
                subtitleRenderer.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            ])
        }
    }
}

extension PlayerVC: PlayerControlsDelegate {
    func updateCurrentTime(didChangeProgress progress: Double) {
        playerVM.isEditingCurrentTime = true
        playerVM.currentTime = (playerVM.duration ?? 0.0) * progress
        playerVM.isEditingCurrentTime = false
    }

    func skipTime(offset: Double) {
        playerVM.isEditingCurrentTime = true
        playerVM.currentTime += offset
        playerVM.isEditingCurrentTime = false
    }

    func playPauseTapped() {
        if playerVM.isPlaying {
            playerVM.player.pause()
        } else {
            playerVM.player.play()
        }
    }

    func showMediaSelector() {
        UIView.animate(withDuration: 0.2) {
            self.mediaSelector.alpha = 1.0
        }
    }

    func navigateBack() {
        showBlackOverlay()
        shouldForceLandscape = false

        self.applyGeometryUpdate(interfaceOrientation: .portrait)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func updateSubtitleOffset(_ offset: Double) {
        subtitleRenderer.offset = offset
        subtitleRenderer.updateLabelSizes()
    }

    func updateSelectedServer(_ index: Int) {
        if let serverLength = store.serverLists?.first?.list.count,
           serverLength > index,
           let serverUrl = store.serverLists?.first?.list[index].url {
            print("Getting data for \(store.serverLists?.first?.list[index].name)")
            store.send(.view(.getSources(serverUrl)))
        }
    }

    func updateSelectedQuality(_ index: Int) {
        guard let sources = self.store.videoData?.streams,
              sources.count > index else {
            return
        }

        // store current time
        let storedCurrentTime = self.playerVM.currentTime

        DispatchQueue.global(qos: .userInitiated).async {
            if let url = URL(string: sources[index].file) {
                let asset = AVAsset(url: url)
                let item = AVPlayerItem(asset: asset)

                DispatchQueue.main.async {
                    self.playerVM.setCurrentItem(item)
                    self.playerVM.isEditingCurrentTime = true
                    self.playerVM.currentTime = storedCurrentTime
                    self.playerVM.isEditingCurrentTime = false
                    self.controls.showPlayButton()

                    self.timeObserver = self.playerVM.player
                        .addPeriodicTimeObserver(
                            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                            queue: .main
                        ) { [weak self] time in
                            guard let self = self else { return }

                            self.controls.currentTimeLabel.text = self.formatTime(time.seconds)
                            if let duration = self.playerVM.duration {
                                self.view.layoutIfNeeded()
                                UIView.animate(withDuration: 0.1) {
                                    self.controls.progressBar.updateProgress(time.seconds / duration)
                                    self.view.layoutIfNeeded()
                                }
                                self.controls.duration = duration
                                self.controls.durationLabel.text = self.formatTime(duration)
                            }
                        }
                }
            }
        }
    }

}

extension PlayerVC {
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3_600
        let minutes = (Int(time) % 3_600) / 60
        let seconds = Int(time) % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

extension PlayerVC: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
