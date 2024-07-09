//
//  Seekbar.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 09.02.24.
//

import Architecture
import UIKit

public protocol SeekBarDelegate: AnyObject {
    func seekBar(_ seekBar: SeekBar, didChangeProgress progress: Double)
}

public class SeekBar: UIView {

    public var width: Double = UIScreen.main.bounds.width
    public var progress: Double = 0.0

    public weak var delegate: SeekBarDelegate?

    public var isDragging = false

    public var lastOffset: Double = 0.0

    // swiftlint:disable implicitly_unwrapped_optional
    public var progressTrailingConstraint: NSLayoutConstraint!
    public var progressWidthConstraint: NSLayoutConstraint!
    public var heightConstraint: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .border
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .fg)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: Lifecycle
    public init(progress: Double) {
        self.progress = progress
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    // MARK: View Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(progressView)
        addSubview(bgView)

        // setup drag gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    // MARK: Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bgView.widthAnchor.constraint(equalTo: widthAnchor),
            bgView.centerYAnchor.constraint(equalTo: centerYAnchor),

            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: width)
        progressWidthConstraint.isActive = true

        heightConstraint = bgView.heightAnchor.constraint(equalToConstant: 6)
        heightConstraint.isActive = true

        let constant = width * progress

        progressTrailingConstraint = progressView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: constant)
        progressTrailingConstraint.isActive = true

        lastOffset = constant
    }

    public func updateProgress(_ newProgress: Double) {
        let newConstant = min(max(newProgress * width, 0.0), width)
        progressTrailingConstraint.constant = newConstant
        lastOffset = newConstant
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        isDragging = true

        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.heightConstraint.constant = 12
            self.bgView.layer.cornerRadius = 6
            self.layoutIfNeeded() // Forces layout update immediately to animate smoothly
        }

        let translation = gestureRecognizer.translation(in: self)

        switch gestureRecognizer.state {
        case .changed:
            print(translation.x)
            progressTrailingConstraint.constant = min(max(translation.x + self.lastOffset, 0.0), width)
            progress = progressTrailingConstraint.constant / width
            delegate?.seekBar(self, didChangeProgress: progress)
            self.layoutIfNeeded()
        case .ended:
            isDragging = false

            progressTrailingConstraint.constant = min(max(translation.x + lastOffset, 0.0), width)
            progress = progressTrailingConstraint.constant / width
            delegate?.seekBar(self, didChangeProgress: progress)

            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.heightConstraint.constant = 6
                self.bgView.layer.cornerRadius = 3
                self.layoutIfNeeded() // Forces layout update immediately to animate smoothly
            }

            lastOffset = min(max(translation.x + self.lastOffset, 0.0), width)
        default:
            break
        }
    }

}
