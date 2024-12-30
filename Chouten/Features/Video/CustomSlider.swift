//
//  CustomSlider.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import UIKit

class CustomSlider: UISlider {
    
    // Initializer for programmatic use
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }
    
    // Initializer for storyboard or xib
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSlider()
    }
    
    private func setupSlider() {
        // Hide the thumb by setting it to a transparent image
        self.setThumbImage(UIImage(), for: .normal)
        
        // Set up track images to simulate different heights and corner radii
        self.setMinimumTrackImage(trackImage(height: 12, rounded: false, color: .systemBlue), for: .highlighted) // Active track
        self.setMinimumTrackImage(trackImage(height: 8, rounded: false, color: .white), for: .normal)       // Inactive track
        self.setMaximumTrackImage(trackImage(height: 8, rounded: true, color: .systemGray5), for: .normal)       // Background track with rounded corners
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    // Helper function to create track images with custom heights and corner radius
    private func trackImage(height: CGFloat, rounded: Bool, color: UIColor) -> UIImage? {
        let size = CGSize(width: 1, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        if rounded {
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: height / 2)
            path.fill()
        } else {
            context?.fill(CGRect(origin: .zero, size: size))
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.resizableImage(withCapInsets: .zero)
    }
}
