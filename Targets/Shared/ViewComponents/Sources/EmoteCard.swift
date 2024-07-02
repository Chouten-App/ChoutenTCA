//
//  EmoteCard.swift
//  ViewComponents
//
//  Created by Inumaki on 23.05.24.
//

import Architecture
import UIKit

public class EmoteCard: UIView {

    let emoteString: String
    let descriptionString: String

    let emoteLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textAlignment = .center
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.alpha = 0.6
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description."
        label.textAlignment = .center
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.alpha = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public init(_ emote: String, description: String) {
        self.emoteString = emote
        self.descriptionString = description
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override public required init(frame: CGRect) {
        self.emoteString = ""
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

        emoteLabel.text = emoteString
        descriptionLabel.text = descriptionString

        addSubview(emoteLabel)
        addSubview(descriptionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emoteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emoteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            emoteLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            descriptionLabel.topAnchor.constraint(equalTo: emoteLabel.bottomAnchor, constant: 2),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
