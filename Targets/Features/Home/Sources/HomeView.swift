//
//  HomeView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 05.03.24.
//

import Architecture
import UIKit

public class HomeView: UIViewController {
    let soonLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon!"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        configure()
        setupConstraints()
    }

    private func configure() {
        view.addSubview(soonLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            soonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            soonLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        soonLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    }
}
