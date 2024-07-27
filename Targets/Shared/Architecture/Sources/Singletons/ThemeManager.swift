//
//  ThemeManager.swift
//  Architecture
//
//  Created by Inumaki on 22.06.24.
//

import UIKit

public struct ThemeColor {
    public var light: UIColor
    public var dark: UIColor

    public init(light: UIColor, dark: UIColor) {
        self.light = light
        self.dark = dark
    }
}

public enum ThemeColorEnum {
    case bg
    case container
    case overlay
    case fg
    case border
    case accent
}

public class ThemeManager {
    public static let shared = ThemeManager()

    public var bg: ThemeColor
    public var container: ThemeColor
    public var overlay: ThemeColor
    public var fg: ThemeColor
    public var border: ThemeColor
    public var accent: Int

    public let accentColors: [UIColor] = [
        .systemIndigo, .systemRed, .systemGreen, .systemBlue, .systemYellow, .systemOrange
    ]

    public let accentColorNames: [String] = [
        "Indigo", "Red", "Green", "Blue", "Yellow", "Orange"
    ]

    private init() {
        // Default theme
        self.bg = ThemeColor(
            light: UIColor(hex: "#EFEFEF"),
            dark: UIColor(hex: "#0c0c0c")
        )
        self.container = ThemeColor(
            light: UIColor(hex: "#FFFFFF"),
            dark: UIColor(hex: "#171717")
        )
        self.overlay = ThemeColor(
            light: UIColor(hex: "#E4E4E4"),
            dark: UIColor(hex: "#272727")
        )
        self.fg = ThemeColor(
            light: UIColor(hex: "#0c0c0c"),
            dark: UIColor(hex: "#d4d4d4")
        )
        self.border = ThemeColor(
            light: UIColor(hex: "#BBBBBB"),
            dark: UIColor(hex: "#3B3B3B")
        )
        self.accent = 0
    }

    public func getColor(for type: ThemeColorEnum, light: Bool? = nil) -> UIColor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let currentStyle = window?.overrideUserInterfaceStyle // UIScreen.main.traitCollection.userInterfaceStyle
        switch type {
        case .bg:
            if let light {
                return light ? bg.light : bg.dark
            }
            return currentStyle == .light ? bg.light : bg.dark
        case .container:
            if let light {
                return light ? container.light : container.dark
            }
            return currentStyle == .light ? container.light : container.dark
        case .overlay:
            if let light {
                return light ? overlay.light : overlay.dark
            }
            return currentStyle == .light ? overlay.light : overlay.dark
        case .fg:
            if let light {
                return light ? fg.light : fg.dark
            }
            return currentStyle == .light ? fg.light : fg.dark
        case .border:
            if let light {
                return light ? border.light : border.dark
            }
            return currentStyle == .light ? border.light : border.dark
        case .accent:
            return accentColors[accent]
        }
    }

    // swiftlint:disable function_parameter_count
    func applyTheme(bg: ThemeColor, container: ThemeColor, overlay: ThemeColor, fg: ThemeColor, border: ThemeColor, accent: Int) {
        self.bg = bg
        self.container = container
        self.overlay = overlay
        self.fg = fg
        self.border = border
        self.accent = accent

        // Notify the app that the theme has changed
        NotificationCenter.default.post(name: NSNotification.Name("ThemeDidChange"), object: nil)
    }
    // swiftlint:enable function_parameter_count

    func applyTheme(fromFile path: String) { }
}

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
