//
//  CustomVideoPlayer.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 09.02.24.
//

import AVKit
import UIKit

class CustomVideoPlayer: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerVM: PlayerViewModel?
    private var pictureInPictureController: AVPictureInPictureController?

    init(playerVM: PlayerViewModel) {
        super.init(frame: .zero)
        self.playerVM = playerVM
        setupPlayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPlayer() {
        player = playerVM?.player
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = bounds
        // swiftlint:disable force_unwrapping
        layer.addSublayer(playerLayer!)
        // swiftlint:enable force_unwrapping
        setupPictureInPictureController()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update the frame of the player layer to match the bounds of the view
        playerLayer?.frame = bounds
    }

    private func setupPictureInPictureController() {
        // swiftlint:disable force_unwrapping
        pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer!)
        // swiftlint:enable force_unwrapping
        pictureInPictureController?.canStartPictureInPictureAutomaticallyFromInline = true
        pictureInPictureController?.delegate = self
    }
}

extension CustomVideoPlayer: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        playerVM?.isInPipMode = true
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        playerVM?.isInPipMode = false
    }
}
