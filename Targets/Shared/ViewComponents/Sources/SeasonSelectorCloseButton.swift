//
//  PlusButton.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 29.01.24.
//

import Architecture
import UIKit

class SeasonSelectorCloseButton: UIButton {
    var tapHandler: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }

    init(tapHandler: @escaping (() -> Void)) {
        self.tapHandler = tapHandler
        super.init(frame: .zero)
    }

    private func setupButton() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(
            UIImage(systemName: "xmark")?
                .withRenderingMode(.alwaysTemplate)
                .applyingSymbolConfiguration(
                    .init(
                        font: .systemFont(ofSize: 14, weight: .bold)
                    )
                ),
            for: .normal
        )
        imageView?.tintColor = ThemeManager.shared.getColor(for: .bg)
        imageView?.contentMode = .scaleAspectFit
        imageView?.translatesAutoresizingMaskIntoConstraints = false

        var configuration = UIButton.Configuration.plain()
        configuration.baseBackgroundColor = ThemeManager.shared.getColor(for: .fg)
        configuration.baseForegroundColor = ThemeManager.shared.getColor(for: .bg)
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15)
        self.configuration = configuration

        backgroundColor = ThemeManager.shared.getColor(for: .fg)
        layer.cornerRadius = 22

        layer.borderWidth = 0.5
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        // Handle tap action here, e.g., show SettingsView in a popover
        tapHandler?()
    }
}

extension SeasonSelectorCloseButton: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
