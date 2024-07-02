//
//  PlusButton.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 29.01.24.
//

import Architecture
import UIKit

public class PlusButton: UIButton {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(
            UIImage(systemName: "plus")?
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
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        self.configuration = configuration

        backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        layer.cornerRadius = 14

        layer.borderWidth = 0.5
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 28),
            heightAnchor.constraint(equalToConstant: 28)
        ])

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
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
        showErrorDisplay(message: "Unimplemented", description: "Adding Shows to a list has not been implemented yet.")
    }
}

extension PlusButton: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
