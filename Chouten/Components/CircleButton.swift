//
//  CircleButton.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import UIKit

 class CircleButton: UIButton {

     var iconName: String {
        didSet {
            updateIcon()  // Call this method whenever iconName changes
        }
    }
     let size: Double
     var onTap: (() -> Void)?
     var hasInteraction: Bool

    override  init(frame: CGRect) {
        self.iconName = "xmark"
        self.size = 10.0
        self.hasInteraction = false
        super.init(frame: frame)
        setupButton()
        updateIcon()
    }

     required init?(coder aDecoder: NSCoder) {
        self.iconName = "xmark"
        self.size = 10.0
        self.hasInteraction = false
        super.init(coder: aDecoder)
        setupButton()
        updateIcon()
    }

     init(icon: String, size: Double = 10.0, onTap: (() -> Void)? = nil, hasInteraction: Bool = false) {
        self.iconName = icon
        self.size = size
        self.onTap = onTap
        self.hasInteraction = hasInteraction
        super.init(frame: .zero)
        setupButton()
        updateIcon()
    }

    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(
            UIImage(systemName: iconName)?
                .withRenderingMode(.alwaysTemplate)
                .applyingSymbolConfiguration(
                    .init(
                        font: .systemFont(ofSize: size)
                    )
                ),
            for: .normal
        )
        imageView?.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.baseBackgroundColor = ThemeManager.shared.getColor(for: .overlay)
        configuration.baseForegroundColor = ThemeManager.shared.getColor(for: .fg)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        self.configuration = configuration

        backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        layer.cornerRadius = 14

        layer.borderWidth = 0.5
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 28),
            heightAnchor.constraint(equalToConstant: 28)
        ])
        
        updateIcon()

        if !hasInteraction {
            addTarget(self, action: #selector(handleTap), for: .touchUpInside) // Add this line
        }
    }

    override  func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        self.configuration?.baseBackgroundColor = ThemeManager.shared.getColor(for: .overlay)
        self.configuration?.baseForegroundColor = ThemeManager.shared.getColor(for: .fg)
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView?.tintColor = ThemeManager.shared.getColor(for: .fg)
    }
    
    private func updateIcon() {
        setImage(
            UIImage(systemName: iconName)?
                .withRenderingMode(.alwaysTemplate)
                .applyingSymbolConfiguration(
                    .init(
                        font: .systemFont(ofSize: size)
                    )
                ),
            for: .normal
        )
    }

    @objc private func handleTap() {
        onTap?()
    }
}
