//
//  PlayerView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 09.02.24.
//

import AVFoundation
import UIKit

class PlayerView: UIView {

    // Override the property to make AVPlayerLayer the view's backing layer.
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    // The associated player object.
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    // swiftlint:disable force_cast
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    // swiftlint:enable force_cast
}
