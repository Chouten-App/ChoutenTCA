//
//  UIView+Extensions.swift
//  Architecture
//
//  Created by Inumaki on 18.03.24.
//

import UIKit

extension UIView {
    public func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        if let sublayers = layer.sublayers {
            for sublayer in sublayers where sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        layer.insertSublayer(gradientLayer, at: 0)
    }
}
