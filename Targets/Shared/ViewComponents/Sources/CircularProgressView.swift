//
//  CircularProgressView.swift
//  ViewComponents
//
//  Created by Inumaki on 20.07.24.
//

import Architecture
import UIKit

public class CircularProgressView: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    public var progressColor: UIColor = ThemeManager.shared.getColor(for: .accent) {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    public var trackColor: UIColor = ThemeManager.shared.getColor(for: .overlay) {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    public var progress: CGFloat = 0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        trackLayer.path = circularPath().cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 6.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)

        progressLayer.path = circularPath().cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 6.0
        progressLayer.strokeEnd = 0.0
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    }

    private func circularPath() -> UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: frame.size.width / 2, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.path = circularPath().cgPath
        progressLayer.path = circularPath().cgPath
    }
}
