//
//  PlayerControlsController.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 09.02.24.
//

import Architecture
import UIKit
import ViewComponents

protocol PlayerControlsDelegate: AnyObject {
    func updateCurrentTime(didChangeProgress progress: Double)
    func playPauseTapped()
    func navigateBack()
}

class PlayerControlsController: UIViewController {

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
    var showUI = true

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

    var playPauseButton = AnimatedButton()

    let backButton = CircleButton(icon: "chevron.left")

    let activityIndicator = UIActivityIndicatorView(style: .medium)

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

        backButton.onTap = {
            self.delegate?.navigateBack()
        }

        forwardButton.addSubview(forwardIcon)
        forwardButton.addSubview(forwardText)
        view.addSubview(forwardButton)

        progressBar.delegate = self

        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(updateUI))
        view.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),

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
            forwardButton.heightAnchor.constraint(equalToConstant: 28)
        ])
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
