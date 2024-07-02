import AVKit
import ComposableArchitecture
import SharedModels
import UIKit

public class PlayerVC: UIViewController {
    var store: Store<VideoFeature.State, VideoFeature.Action>

    let data: MediaItem
    let info: InfoData
    let playerVM = PlayerViewModel()
    let controls = PlayerControlsController()
    lazy var customVideoPlayer = CustomVideoPlayer(playerVM: playerVM)

    private var timeObserver: Any?
    private var blackOverlayView: UIView?

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

    public init(data: MediaItem, info: InfoData) {
        self.data = data
        self.info = info
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
        addChild(controls)
        view.addSubview(controls.view)
        controls.didMove(toParent: self)

        controls.delegate = self

        // Set data of UI
        controls.subtitleLabel.text = data.title ?? "Episode \(data.number)"
        controls.titleLabel.text = info.titles.primary

        NSLayoutConstraint.activate([
            customVideoPlayer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customVideoPlayer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customVideoPlayer.topAnchor.constraint(equalTo: view.topAnchor),
            customVideoPlayer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            controls.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controls.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controls.view.topAnchor.constraint(equalTo: view.topAnchor),
            controls.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(updateUI))
        view.addGestureRecognizer(tapGesture)

        observe { [weak self] in
            guard let self = self else { return }

            switch store.status {
            case .loading:
                break
            case .success:
                if let url = URL(string: store.videoData?.sources.first?.file ?? "") {
                    let asset = AVAsset(url: url)
                    let item = AVPlayerItem(asset: asset)
                    playerVM.setCurrentItem(item)
                    controls.showPlayButton()

                    timeObserver = playerVM.player
                        .addPeriodicTimeObserver(
                            forInterval: CMTime(seconds: 1, preferredTimescale: 1),
                            queue: .main
                        ) { [weak self] time in
                        guard let self = self else { return }

                        self.controls.currentTimeLabel.text = self.formatTime(time.seconds)
                        if let duration = playerVM.duration {
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

    @objc
    public func updateUI() {
        UIView.animate(withDuration: 0.2) {
            self.controls.view.alpha = 1.0
        }
    }

    deinit {
        if let observer = timeObserver {
            playerVM.player.removeTimeObserver(observer)
        }
    }
}

extension PlayerVC: PlayerControlsDelegate {
    func updateCurrentTime(didChangeProgress progress: Double) {
        playerVM.isEditingCurrentTime = true
        playerVM.currentTime = (playerVM.duration ?? 0.0) * progress
        playerVM.isEditingCurrentTime = false
    }

    func playPauseTapped() {
        if playerVM.isPlaying {
            playerVM.player.pause()
        } else {
            playerVM.player.play()
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
