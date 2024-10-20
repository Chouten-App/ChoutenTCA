//
//  UIColor+Extensions.swift
//  Chouten
//
//  Created by Inumaki on 14/10/2024.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }

        if hexString.count != 6 {
            self.init(white: 1.0, alpha: 1.0)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    static var bg = ThemeManager.shared.getColor(for: .bg)
    static var container = ThemeManager.shared.getColor(for: .container)
    static var overlay = ThemeManager.shared.getColor(for: .overlay)
    static var fg = ThemeManager.shared.getColor(for: .fg)
    static var accent = ThemeManager.shared.getColor(for: .accent)
    
    static var border = ThemeManager.shared.getColor(for: .border)
}
