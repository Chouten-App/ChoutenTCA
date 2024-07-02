//
//  LoadingSeasonDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 22.02.24.
//

import Architecture
import UIKit

public class LoadingSeasonDisplay: UIView {

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let seasonLabel: UIView = {
        let label = UIView()
        label.backgroundColor = ThemeManager.shared.getColor(for: .container)
        label.layer.cornerRadius = 4
        label.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        label.layer.borderWidth = 0.5
        label.alpha = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let seasonButton = CircleButton(icon: "chevron.right")

    let mediaCountLabel: UIView = {
        let label = UIView()
        label.backgroundColor = ThemeManager.shared.getColor(for: .container)
        label.layer.cornerRadius = 4
        label.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        label.layer.borderWidth = 0.5
        label.alpha = 0.8
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
        updateData()
    }

    // MARK: View Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
        updateData()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func configure() {
        addSubview(seasonLabel)
        addSubview(seasonButton)

        addSubview(mediaCountLabel)
    }

    private func updateData() { }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            seasonLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            seasonLabel.widthAnchor.constraint(equalToConstant: 120),
            seasonLabel.heightAnchor.constraint(equalToConstant: 20),
            seasonLabel.topAnchor.constraint(equalTo: topAnchor),

            mediaCountLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            mediaCountLabel.widthAnchor.constraint(equalToConstant: 60),
            mediaCountLabel.heightAnchor.constraint(equalToConstant: 14),
            mediaCountLabel.topAnchor.constraint(equalTo: seasonLabel.bottomAnchor, constant: 6),

            seasonButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            seasonButton.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
}
