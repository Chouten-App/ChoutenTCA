//  profileCard.swift
//  Chouten
//
//  Created by Resty on 23.01.25.
//

import UIKit

let profileCardTop: UIView = {
    let card = UIView()
    card.backgroundColor = ThemeManager.shared.getColor(for: .container)
    card.layer.cornerRadius = 20
    card.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
    card.layer.borderWidth = 0.5
    card.translatesAutoresizingMaskIntoConstraints = false

    let verticalStack = UIStackView()
    verticalStack.axis = .vertical
    verticalStack.alignment = .center
    verticalStack.spacing = 2
    verticalStack.translatesAutoresizingMaskIntoConstraints = false

    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let url = URL(string: "https://avatars.githubusercontent.com/u/33759526?v=4") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        return imageView
    }()

    let nameLabel = UILabel()
    nameLabel.text = "Inumaki"
    nameLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    let subtitleLabel = UILabel()
    subtitleLabel.text = "Main Developer"
    subtitleLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    subtitleLabel.font = UIFont.systemFont(ofSize: 14)
    subtitleLabel.alpha = 0.7
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    verticalStack.addArrangedSubview(profileImage)
    verticalStack.setCustomSpacing(5, after: profileImage)
    verticalStack.addArrangedSubview(nameLabel)
    verticalStack.addArrangedSubview(subtitleLabel)
    card.addSubview(verticalStack)

    NSLayoutConstraint.activate([
        // Card constraints
        card.widthAnchor.constraint(equalToConstant: 250),
        card.heightAnchor.constraint(equalToConstant: 160),

        // Vertical stack constraints
        verticalStack.centerXAnchor.constraint(equalTo: card.centerXAnchor),
        verticalStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        verticalStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
        verticalStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -15),

        // Profile image constraints
        profileImage.widthAnchor.constraint(equalToConstant: 80),
        profileImage.heightAnchor.constraint(equalToConstant: 80)
    ])

    return card
}()
