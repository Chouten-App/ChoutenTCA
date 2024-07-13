//
//  PlayerControlsController.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 09.02.24.
//

import Architecture
import SharedModels
import UIKit
import ViewComponents

protocol PlayerControlsDelegate: AnyObject {
    func updateCurrentTime(didChangeProgress progress: Double)
    func skipTime(offset: Double)
    func playPauseTapped()
    func navigateBack()
    func updateSelectedQuality(_ index: Int)
    func updateSelectedServer(_ index: Int)
    func updateSubtitleOffset(_ offset: Double)
    func nextEpisode()
    func showMediaSelector()
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// swiftlint:disable type_body_length
class PlayerControlsController: UIViewController {
    var data: MediaStream?
    var servers: [SourceList]?
    var selectedSourceIndex: Int?
    var selectedServerIndex: Int?
    var selectedSubtitleOffset = 0.0
    var progressBar = SeekBar(progress: 0.0)
    var progress: Double = 0.0
    var duration: Double = 0.0
    var isPlaying = false {
        didSet {
            let image = UIImage(systemName: isPlaying ? "pause.fill" : "play.fill")?.withRenderingMode(.alwaysTemplate)
            playPauseButton.setImage(image, for: .normal)
            view.layoutIfNeeded()
        }
    }

    weak var delegate: PlayerControlsDelegate?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Re:ZERO -Starting Life in Another World-"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Episode 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 10)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let durationLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 10)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Backward button
    let backwardButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let backwardIcon: UIImageView = {
        let view = UIImageView(
            image: UIImage(systemName: "gobackward")?
                .withRenderingMode(.alwaysTemplate)
                .applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 28)))
        )
        view.tintColor = ThemeManager.shared.getColor(for: .fg)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let backwardText: UILabel = {
        let label = UILabel()
        label.text = "-10"
        label.font = .systemFont(ofSize: 8, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Forward button
    let forwardButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let forwardIcon: UIImageView = {
        let view = UIImageView(
            image: UIImage(systemName: "goforward")?
                .withRenderingMode(.alwaysTemplate)
                .applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 28)))
        )
        view.tintColor = ThemeManager.shared.getColor(for: .fg)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let forwardText: UILabel = {
        let label = UILabel()
        label.text = "+10"
        label.font = .systemFont(ofSize: 8, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let fastForwardWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let fastForwardText: UILabel = {
        let label = UILabel()
        label.text = "Fast forward (2x)"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var playPauseButton = AnimatedButton()

    let backButton = CircleButton(icon: "chevron.left")

    let skipEpisodeButton = CircleButton(icon: "forward.fill", size: 8)

    let mediaSelectorButton = CircleButton(icon: "play.rectangle.on.rectangle.fill", size: 8)

    let settingsButton = CircleButton(icon: "gear", hasInteraction: true)

    let activityIndicator = UIActivityIndicatorView(style: .medium)

    let nextEpisodeButton: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let nextEpisodeProgress: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .fg)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let nextEpisodeTextWrapper: UIView = {
        let view = UIView()
        view.layer.compositingFilter = "differenceBlendMode"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let nextEpisodeText: UILabel = {
        let label = UILabel()
        label.text = "Next Episode"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black.withAlphaComponent(0.6)

        view.addSubview(backButton)

        view.addSubview(progressBar)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)

        playPauseButton = AnimatedButton { _ in
            self.delegate?.playPauseTapped()
        }

        activityIndicator.tintColor = ThemeManager.shared.getColor(for: .fg)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        playPauseButton.alpha = 0.0
        playPauseButton.isUserInteractionEnabled = false
        view.addSubview(playPauseButton)

        backwardButton.addSubview(backwardIcon)
        backwardButton.addSubview(backwardText)
        view.addSubview(backwardButton)
        view.addSubview(mediaSelectorButton)
        view.addSubview(settingsButton)

        view.addSubview(skipEpisodeButton)

        skipEpisodeButton.onTap = {
            self.delegate?.nextEpisode()
        }

        backButton.onTap = {
            self.delegate?.navigateBack()
        }

        mediaSelectorButton.onTap = {
            self.delegate?.showMediaSelector()
        }

        settingsButton.menu = {
            let servers = UIMenu(title: "Servers", image: UIImage(systemName: "server.rack"), children: [
                UIAction(title: "Submenu Action 1", image: UIImage(systemName: "square.and.arrow.up")) { action in
                    print("Submenu Action 1 selected")
                },
                UIAction(title: "Submenu Action 2", image: UIImage(systemName: "square.and.arrow.down")) { action in
                    print("Submenu Action 2 selected")
                }
            ])

            if let data {
                let qualities = UIMenu(
                    title: "Qualities",
                    image: UIImage(systemName: "slider.horizontal.3"),
                    children: data.streams.compactMap { source in
                        return UIAction(title: source.quality) { action in
                            print("Submenu Action 3 selected")
                        }
                    }
                )
                return UIMenu(title: "Settings", children: [servers, qualities])
            }

            // Create and return a UIMenu with the actions
            return UIMenu(title: "Settings", children: [servers])
        }()
        settingsButton.showsMenuAsPrimaryAction = true

        forwardButton.addSubview(forwardIcon)
        forwardButton.addSubview(forwardText)
        view.addSubview(forwardButton)

        fastForwardWrapper.addSubview(fastForwardText)
        view.addSubview(fastForwardWrapper)

        nextEpisodeButton.addSubview(nextEpisodeProgress)
        nextEpisodeTextWrapper.addSubview(nextEpisodeText)
        nextEpisodeButton.addSubview(nextEpisodeTextWrapper)
        view.addSubview(nextEpisodeButton)

        nextEpisodeButton.alpha = 0.0

        fastForwardWrapper.alpha = 0.0

        progressBar.delegate = self

        forwardButton.isUserInteractionEnabled = true
        let forwardTapGesture = UITapGestureRecognizer(target: self, action: #selector(skipForward))
        forwardButton.addGestureRecognizer(forwardTapGesture)

        backwardButton.isUserInteractionEnabled = true
        let backwardTapGesture = UITapGestureRecognizer(target: self, action: #selector(skipBackward))
        backwardButton.addGestureRecognizer(backwardTapGesture)

        // view.isUserInteractionEnabled = false

//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(updateUI))
//        view.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: 12),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),

            settingsButton.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: -12),
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),

            currentTimeLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: 12),

            durationLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            durationLabel.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: -12),

            progressBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            progressBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            progressBar.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor, constant: 12),
            titleLabel.widthAnchor.constraint(equalToConstant: 280),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -2),

            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // backward button
            backwardIcon.centerXAnchor.constraint(equalTo: backwardButton.centerXAnchor),
            backwardIcon.centerYAnchor.constraint(equalTo: backwardButton.centerYAnchor),

            backwardText.centerXAnchor.constraint(equalTo: backwardButton.centerXAnchor),
            backwardText.centerYAnchor.constraint(equalTo: backwardButton.centerYAnchor),

            backwardButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -60),
            backwardButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            backwardIcon.widthAnchor.constraint(equalToConstant: 28),
            backwardIcon.heightAnchor.constraint(equalToConstant: 28),
            backwardButton.widthAnchor.constraint(equalToConstant: 28),
            backwardButton.heightAnchor.constraint(equalToConstant: 28),

            // forward button
            forwardIcon.centerXAnchor.constraint(equalTo: forwardButton.centerXAnchor),
            forwardIcon.centerYAnchor.constraint(equalTo: forwardButton.centerYAnchor),

            forwardText.centerXAnchor.constraint(equalTo: forwardButton.centerXAnchor),
            forwardText.centerYAnchor.constraint(equalTo: forwardButton.centerYAnchor),

            forwardButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 60),
            forwardButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            forwardIcon.widthAnchor.constraint(equalToConstant: 28),
            forwardIcon.heightAnchor.constraint(equalToConstant: 28),
            forwardButton.widthAnchor.constraint(equalToConstant: 28),
            forwardButton.heightAnchor.constraint(equalToConstant: 28),

            fastForwardWrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            fastForwardWrapper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fastForwardWrapper.heightAnchor.constraint(equalToConstant: 28),

            fastForwardText.leadingAnchor.constraint(equalTo: fastForwardWrapper.leadingAnchor, constant: 12),
            fastForwardText.trailingAnchor.constraint(equalTo: fastForwardWrapper.trailingAnchor, constant: -12),
            fastForwardText.centerYAnchor.constraint(equalTo: fastForwardWrapper.centerYAnchor),

            nextEpisodeButton.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            nextEpisodeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),

            nextEpisodeProgress.leadingAnchor.constraint(equalTo: nextEpisodeButton.leadingAnchor),
            nextEpisodeProgress.trailingAnchor.constraint(equalTo: nextEpisodeButton.trailingAnchor),
            nextEpisodeProgress.topAnchor.constraint(equalTo: nextEpisodeButton.topAnchor),
            nextEpisodeProgress.bottomAnchor.constraint(equalTo: nextEpisodeButton.bottomAnchor),

            nextEpisodeTextWrapper.leadingAnchor.constraint(equalTo: nextEpisodeButton.leadingAnchor),
            nextEpisodeTextWrapper.trailingAnchor.constraint(equalTo: nextEpisodeButton.trailingAnchor),
            nextEpisodeTextWrapper.topAnchor.constraint(equalTo: nextEpisodeButton.topAnchor),
            nextEpisodeTextWrapper.bottomAnchor.constraint(equalTo: nextEpisodeButton.bottomAnchor),

            nextEpisodeText.leadingAnchor.constraint(equalTo: nextEpisodeTextWrapper.leadingAnchor, constant: 12),
            nextEpisodeText.trailingAnchor.constraint(equalTo: nextEpisodeTextWrapper.trailingAnchor, constant: -12),
            nextEpisodeText.topAnchor.constraint(equalTo: nextEpisodeTextWrapper.topAnchor, constant: 8),
            nextEpisodeText.bottomAnchor.constraint(equalTo: nextEpisodeTextWrapper.bottomAnchor, constant: -8),

            skipEpisodeButton.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: 8),
            skipEpisodeButton.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: -12),

            mediaSelectorButton.trailingAnchor.constraint(equalTo: skipEpisodeButton.leadingAnchor, constant: -12),
            mediaSelectorButton.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: 8),
        ])
    }

    func updateData() {
        settingsButton.menu = {
            var submenus: [UIMenu] = []

            if let servers {
                let serversList = UIMenu(
                    title: "Servers",
                    image: UIImage(systemName: "server.rack"),
                    children: servers.compactMap { serverList in
                        let serverItems = serverList.list.enumerated().compactMap { index, serverData in
                            UIAction(title: serverData.name, state: index == selectedServerIndex ? .on : .off) { action in
                                self.selectedServerIndex = index
                                self.delegate?.updateSelectedServer(index)
                            }
                        }

                        return UIMenu(title: serverList.title, children: serverItems)
                    }
                )

                submenus.append(serversList)
            }

            if let data {
                let qualities = UIMenu(
                    title: "Qualities",
                    image: UIImage(systemName: "slider.horizontal.3"),
                    children: data.streams.enumerated().compactMap { (index, source) in
                        UIAction(title: source.quality, state: index == selectedSourceIndex ? .on : .off) { action in
                            self.selectedSourceIndex = index
                            self.delegate?.updateSelectedQuality(index)
                            self.updateData()
                        }
                    }
                )

                submenus.append(qualities)
            }

            var offsets: [Double] = []
            for i in stride(from: -1.0, through: 1.0, by: 0.1) {
                offsets.append(i.round(to: 1))
            }

            let offsetSwitcher = UIMenu(
                title: "Subtitle Offset",
                image: UIImage(systemName: "captions.bubble"),
                children: offsets.compactMap { offset in
                    UIAction(title: "\(offset)", state: offset.round(to: 1) == selectedSubtitleOffset.round(to: 1) ? .on : .off) { _ in
                        self.selectedSubtitleOffset = offset
                        self.delegate?.updateSubtitleOffset(offset)
                    }
                }
            )

            submenus.append(offsetSwitcher)

            // Create and return a UIMenu with the actions
            return UIMenu(title: "Settings", children: submenus)
        }()
    }

    @objc func playPauseTapped() {
        isPlaying.toggle()
        delegate?.playPauseTapped()
    }

    func showPlayButton() {
        UIView.animate(withDuration: 0.2) {
            self.activityIndicator.alpha = 0.0
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.playPauseButton.alpha = 1.0
            } completion: { _ in
                self.playPauseButton.isUserInteractionEnabled = true
            }
        }
    }

    func hidePlayButton() {
        self.playPauseButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2) {
            self.playPauseButton.alpha = 0.0

        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.activityIndicator.alpha = 1.0
            }
        }
    }

    @objc func skipForward() {
        forwardButtonAnimation()
        delegate?.skipTime(offset: 10)
    }

    func forwardButtonAnimation() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
            // rotate icon
            self.forwardIcon.transform = CGAffineTransform(rotationAngle: 20 * CGFloat.pi / 180)

            // translate text
            self.forwardText.transform = CGAffineTransform(translationX: 32, y: 0)
        } completion: { _ in
            // reverse
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
                // rotate icon
                self.forwardIcon.transform = .identity

                // translate text
                self.forwardText.transform = .identity
            }
        }
    }

    @objc func skipBackward() {
        backwardButtonAnimation()
        delegate?.skipTime(offset: -10)
    }

    func backwardButtonAnimation() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
            // rotate icon
            self.backwardIcon.transform = CGAffineTransform(rotationAngle: -(20 * CGFloat.pi / 180))

            // translate text
            self.backwardText.transform = CGAffineTransform(translationX: -32, y: 0)
        } completion: { _ in
            // reverse
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0) {
                // rotate icon
                self.backwardIcon.transform = .identity

                // translate text
                self.backwardText.transform = .identity
            }
        }
    }

    func hideUI(exceptBlack: Bool = false) {
        // hide things manually instead of just the view, to allow for certain components to get shown on gestures
        UIView.animate(withDuration: 0.2) {
            if !exceptBlack {
                self.view.backgroundColor = .black.withAlphaComponent(0.0)
            }

            // do alpha and move animation to make animation more interesting
            self.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 50)
            self.subtitleLabel.alpha = 0.0

            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: 50)
            self.titleLabel.alpha = 0.0

            self.progressBar.transform = CGAffineTransform(translationX: 0, y: 50)
            self.progressBar.alpha = 0.0

            self.skipEpisodeButton.transform = CGAffineTransform(translationX: 0, y: -50)
            self.skipEpisodeButton.alpha = 0.0

            self.currentTimeLabel.transform = CGAffineTransform(translationX: 0, y: 50)
            self.currentTimeLabel.alpha = 0.0

            self.durationLabel.transform = CGAffineTransform(translationX: 0, y: 50)
            self.durationLabel.alpha = 0.0

            self.backButton.transform = CGAffineTransform(translationX: 0, y: -50)
            self.backButton.alpha = 0.0

            self.mediaSelectorButton.transform = CGAffineTransform(translationX: 0, y: -50)
            self.mediaSelectorButton.alpha = 0.0

            self.settingsButton.transform = CGAffineTransform(translationX: 0, y: -50)
            self.settingsButton.alpha = 0.0

            self.playPauseButton.alpha = 0.0
            self.backwardButton.alpha = 0.0
            self.forwardButton.alpha = 0.0
        }
    }

    func showUI() {
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = .black.withAlphaComponent(0.6)

            // Revert the alpha and move animation to show the UI components
            self.subtitleLabel.transform = .identity
            self.subtitleLabel.alpha = 1.0

            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1.0

            self.progressBar.transform = .identity
            self.progressBar.alpha = 1.0

            self.currentTimeLabel.transform = .identity
            self.currentTimeLabel.alpha = 1.0

            self.durationLabel.transform = .identity
            self.durationLabel.alpha = 1.0

            self.backButton.transform = .identity
            self.backButton.alpha = 1.0

            self.mediaSelectorButton.transform = .identity
            self.mediaSelectorButton.alpha = 1.0

            self.settingsButton.transform = .identity
            self.settingsButton.alpha = 1.0

            self.skipEpisodeButton.transform = .identity
            self.skipEpisodeButton.alpha = 1.0

            self.playPauseButton.alpha = 1.0
            self.backwardButton.alpha = 1.0
            self.forwardButton.alpha = 1.0
        }
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Set progressBar's width based on the safe area insets
        progressBar.width = progressBar.frame.width
        progressBar.progressWidthConstraint.constant = progressBar.width
    }

    @objc
    func updateUI() {
        UIView.animate(withDuration: 0.2) {
            self.view.alpha = self.view.alpha == 0.0 ? 1.0 : 0.0
        }
    }
}
// swiftlint:enable type_body_length

extension PlayerControlsController: SeekBarDelegate {
    func seekBar(_ seekBar: SeekBar, didChangeProgress progress: Double) {
        let interval = calculateCurrentTime(from: progress)
        currentTimeLabel.text = formatTime(interval)
        delegate?.updateCurrentTime(didChangeProgress: progress)
    }

    // Helper methods to calculate time
    func calculateCurrentTime(from progress: Double) -> TimeInterval {
        // Assuming progress is in the range of 0 to 1 representing the percentage of progress
        let durationInSeconds = duration
        return progress * TimeInterval(durationInSeconds)
    }

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
