//
//  AnimatedButton.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 12.02.24.
//

import Architecture
import UIKit

public class AnimatedButton: UIButton {

    let animationDuration: TimeInterval = 0.02 // Animation duration in seconds
    var animationTimer: Timer?
    var currentFrameIndex = 0
    public var forward = true
    public var animationCompletionHandler: ((Bool) -> Void)? // Completion handler

    public init(completion: ((Bool) -> Void)?) {
        self.animationCompletionHandler = completion
        super.init(frame: .zero)
        setupButton()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        // backgroundColor = ThemeManager.shared.getColor(for: .container)

        translatesAutoresizingMaskIntoConstraints = false

        setImage(UIImage(named: forward ? "frame0" : "frame9")?.withRenderingMode(.alwaysTemplate), for: .normal)
        imageView?.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false

        imageView?.widthAnchor.constraint(equalToConstant: 42).isActive = true
        imageView?.heightAnchor.constraint(equalToConstant: 42).isActive = true

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 42),
            heightAnchor.constraint(equalToConstant: 42)
        ])

        addTarget(self, action: #selector(animate), for: .touchUpInside)
    }

    @objc func animate() {
        animationCompletionHandler?(!forward) // Animation completed, button is now paused
        animationTimer?.invalidate() // Invalidate any existing timer
        animationTimer = Timer.scheduledTimer(
            timeInterval: animationDuration,
            target: self,
            selector: #selector(animateFrame),
            userInfo: nil,
            repeats: true
        )
    }

    @objc private func animateFrame() {
        if forward {
            currentFrameIndex += 1
            if currentFrameIndex == 9 { // Assuming you have 10 frames from frame0 to frame9
                let imageName = "frame9"
                setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
                forward.toggle()
                animationTimer?.invalidate()
            } else {
                let imageName = "frame\(currentFrameIndex)"
                setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        } else {
            currentFrameIndex -= 1
            if currentFrameIndex == 0 { // Assuming you have 10 frames from frame0 to frame9
                let imageName = "frame0"
                setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
                forward.toggle()
                animationTimer?.invalidate()
            } else {
                let imageName = "frame\(currentFrameIndex)"
                setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        }
    }

    deinit {
        animationTimer?.invalidate()
    }
}
