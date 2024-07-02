//
//  RepoView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 05.03.24.
//

import Architecture
import UIKit

class RepoViewOld: UIViewController {

    let soonLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon!"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

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
}
