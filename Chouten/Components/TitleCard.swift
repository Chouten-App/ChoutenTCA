//
//  TitleCard.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import UIKit

class TitleCard: UIView {

    let titleString: String
    let descriptionString: String

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.alpha = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description."
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.alpha = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(_ title: String, description: String) {
        self.titleString = title
        self.descriptionString = description
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override required init(frame: CGRect) {
        self.titleString = ""
        self.descriptionString = ""
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        layer.cornerRadius = 12
        layer.borderWidth = 0.5
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = titleString
        descriptionLabel.text = descriptionString

        addSubview(titleLabel)
        addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
