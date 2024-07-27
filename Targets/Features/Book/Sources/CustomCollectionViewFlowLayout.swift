//
//  CustomCollectionViewFlowLayout.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 19.07.24.
//

import UIKit

class CustomCollectionViewFlowLayout: UICollectionViewFlowLayout {
    // Custom properties
    var customFlipsHorizontallyInOppositeLayoutDirection: Bool = true {
        didSet {
            invalidateLayout()
        }
    }

    var customDevelopmentLayoutDirection: UIUserInterfaceLayoutDirection = .rightToLeft {
        didSet {
            invalidateLayout()
        }
    }

    // Override the flipsHorizontallyInOppositeLayoutDirection property
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return customFlipsHorizontallyInOppositeLayoutDirection
    }

    // Override the developmentLayoutDirection property
    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return customDevelopmentLayoutDirection
    }

    // Method to set flipsHorizontallyInOppositeLayoutDirection dynamically
    func setFlipsHorizontally(_ flips: Bool) {
        self.customFlipsHorizontallyInOppositeLayoutDirection = flips
    }

    // Method to set developmentLayoutDirection dynamically
    func setDevelopmentLayoutDirection(_ direction: UIUserInterfaceLayoutDirection) {
        self.customDevelopmentLayoutDirection = direction
    }
}
