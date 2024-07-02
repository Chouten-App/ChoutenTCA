//
//  PlusButton.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 29.01.24.
//

import Architecture
import UIKit

public class CircleButton: UIButton {

    public let iconName: String
    public var onTap: (() -> Void)?

    override public init(frame: CGRect) {
        self.iconName = "xmark"
        super.init(frame: frame)
        setupButton()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.iconName = "xmark"
        super.init(coder: aDecoder)
        setupButton()
    }

    public init(icon: String, onTap: (() -> Void)? = nil) {
        self.iconName = icon
        self.onTap = onTap
        super.init(frame: .zero)
        setupButton()
    }

    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(
            UIImage(systemName: iconName)?
                .withRenderingMode(.alwaysTemplate)
                .applyingSymbolConfiguration(
                    .init(
                        font: .systemFont(ofSize: 10)
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

        addTarget(self, action: #selector(handleTap), for: .touchUpInside) // Add this line
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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

    @objc private func handleTap() {
        onTap?()
    }
}
