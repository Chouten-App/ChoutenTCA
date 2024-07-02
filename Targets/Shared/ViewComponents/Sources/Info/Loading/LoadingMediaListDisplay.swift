//
//  LoadingMediaListDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 19.02.24.
//

import Architecture
import UIKit

public class LoadingMediaListDisplay: UIView {

    let contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 12
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
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
        addSubview(contentView)
    }

    private func updateData() {
        for _ in 0..<4 {
            let mediaItemDisplay = UIView()
            mediaItemDisplay.backgroundColor = ThemeManager.shared.getColor(for: .container).withAlphaComponent(0.6)
            mediaItemDisplay.layer.borderColor = ThemeManager.shared.getColor(for: .border).withAlphaComponent(0.6).cgColor
            mediaItemDisplay.layer.borderWidth = 0.5
            mediaItemDisplay.layer.cornerRadius = 12
            mediaItemDisplay.translatesAutoresizingMaskIntoConstraints = false

            let imagePlaceholder = UIView()
            imagePlaceholder.backgroundColor = ThemeManager.shared.getColor(for: .overlay).withAlphaComponent(0.6)
            imagePlaceholder.layer.borderColor = ThemeManager.shared.getColor(for: .border).withAlphaComponent(0.6).cgColor
            imagePlaceholder.layer.borderWidth = 0.5
            imagePlaceholder.layer.cornerRadius = 12
            imagePlaceholder.translatesAutoresizingMaskIntoConstraints = false

            let titlePlaceholder = UIView()
            titlePlaceholder.backgroundColor = ThemeManager.shared.getColor(for: .overlay).withAlphaComponent(0.6)
            titlePlaceholder.layer.borderColor = ThemeManager.shared.getColor(for: .border).withAlphaComponent(0.6).cgColor
            titlePlaceholder.layer.borderWidth = 0.5
            titlePlaceholder.layer.cornerRadius = 4
            titlePlaceholder.translatesAutoresizingMaskIntoConstraints = false

            let subtitlePlaceholder = UIView()
            subtitlePlaceholder.backgroundColor = ThemeManager.shared.getColor(for: .overlay).withAlphaComponent(0.2)
            subtitlePlaceholder.layer.borderColor = ThemeManager.shared.getColor(for: .border).withAlphaComponent(0.2).cgColor
            subtitlePlaceholder.layer.borderWidth = 0.5
            subtitlePlaceholder.layer.cornerRadius = 4
            subtitlePlaceholder.translatesAutoresizingMaskIntoConstraints = false

            contentView.addArrangedSubview(mediaItemDisplay)

            mediaItemDisplay.addSubview(imagePlaceholder)
            mediaItemDisplay.addSubview(titlePlaceholder)
            mediaItemDisplay.addSubview(subtitlePlaceholder)

            NSLayoutConstraint.activate([
                mediaItemDisplay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                mediaItemDisplay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                mediaItemDisplay.heightAnchor.constraint(equalToConstant: 88),

                imagePlaceholder.leadingAnchor.constraint(equalTo: mediaItemDisplay.leadingAnchor, constant: 16),
                imagePlaceholder.centerYAnchor.constraint(equalTo: mediaItemDisplay.centerYAnchor),
                imagePlaceholder.heightAnchor.constraint(equalToConstant: 64),
                imagePlaceholder.widthAnchor.constraint(equalToConstant: 64 / 9 * 16),

                titlePlaceholder.leadingAnchor.constraint(equalTo: imagePlaceholder.trailingAnchor, constant: 16),
                titlePlaceholder.topAnchor.constraint(equalTo: imagePlaceholder.topAnchor, constant: 12),
                titlePlaceholder.heightAnchor.constraint(equalToConstant: 18),
                titlePlaceholder.widthAnchor.constraint(equalToConstant: 60),

                subtitlePlaceholder.leadingAnchor.constraint(equalTo: imagePlaceholder.trailingAnchor, constant: 16),
                subtitlePlaceholder.trailingAnchor.constraint(equalTo: mediaItemDisplay.trailingAnchor, constant: -16),
                subtitlePlaceholder.bottomAnchor.constraint(equalTo: imagePlaceholder.bottomAnchor, constant: -12),
                subtitlePlaceholder.heightAnchor.constraint(equalToConstant: 14)
            ])
        }
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}
