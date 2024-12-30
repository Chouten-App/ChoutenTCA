//
//  ClearButton.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import UIKit

public class ClearButton: UIButton {

    let iconName: String
    var onTap: (() -> Void)?

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
                        font: .systemFont(ofSize: 6)
                    )
                ),
            for: .normal
        )
        imageView?.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.baseForegroundColor = ThemeManager.shared.getColor(for: .bg)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        self.configuration = configuration

        backgroundColor = ThemeManager.shared.getColor(for: .fg).withAlphaComponent(0.5)
        layer.cornerRadius = 8

        layer.borderWidth = 0.5
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 16),
            heightAnchor.constraint(equalToConstant: 16)
        ])

        addTarget(self, action: #selector(handleTap), for: .touchUpInside) // Add this line
    }

    @objc private func handleTap() {
        onTap?()
    }
}
