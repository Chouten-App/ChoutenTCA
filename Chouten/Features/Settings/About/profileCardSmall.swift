import UIKit

struct ProfileCardData {
    let name: String
    let role: String
    let imageUrl: String
    let githubUrl: String
}

func profileCardSmall(for profile: ProfileCardData) -> UIView {
    let card = UIView()
    card.backgroundColor = ThemeManager.shared.getColor(for: .container)
    card.layer.cornerRadius = 15
    card.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
    card.layer.borderWidth = 0.5
    card.translatesAutoresizingMaskIntoConstraints = false

    let horizontalStack = UIStackView()
    horizontalStack.axis = .horizontal
    horizontalStack.alignment = .center
    horizontalStack.spacing = 12
    horizontalStack.translatesAutoresizingMaskIntoConstraints = false

    // Profile image
    let profileImage = UIImageView()
    profileImage.contentMode = .scaleAspectFill
    profileImage.layer.cornerRadius = 25
    profileImage.clipsToBounds = true
    profileImage.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
    profileImage.layer.borderWidth = 0.5
    profileImage.translatesAutoresizingMaskIntoConstraints = false

    // Load profile image from URL
    if let url = URL(string: profile.imageUrl) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    profileImage.image = UIImage(data: data)
                }
            }
        }.resume()
    }

    let textStack = UIStackView()
    textStack.axis = .vertical
    textStack.alignment = .leading
    textStack.spacing = 2
    textStack.translatesAutoresizingMaskIntoConstraints = false

    let nameLabel = UILabel()
    nameLabel.text = profile.name
    nameLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

    let subtitleLabel = UILabel()
    subtitleLabel.text = profile.role
    subtitleLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    subtitleLabel.font = UIFont.systemFont(ofSize: 12)
    subtitleLabel.alpha = 0.7

    textStack.addArrangedSubview(nameLabel)
    textStack.addArrangedSubview(subtitleLabel)

    let githubTransparentIconUrl = "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png"

    // GitHub icon button
    let githubButton = UIButton(type: .custom)
    githubButton.translatesAutoresizingMaskIntoConstraints = false

    if let githubIconUrl = URL(string: githubTransparentIconUrl) {
        URLSession.shared.dataTask(with: githubIconUrl) { data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    githubButton.setImage(UIImage(data: data), for: .normal)
                }
            }
        }.resume()
    }

    githubButton.addAction(UIAction(handler: { _ in
        if let url = URL(string: profile.githubUrl) {
            UIApplication.shared.open(url)
        }
    }), for: .touchUpInside)

    githubButton.layer.cornerRadius = 15
    githubButton.clipsToBounds = true

    githubButton.addAction(UIAction(handler: { _ in
        if let url = URL(string: profile.githubUrl) {
            UIApplication.shared.open(url)
        }
    }), for: .touchUpInside)

    horizontalStack.addArrangedSubview(profileImage)
    horizontalStack.addArrangedSubview(textStack)
    horizontalStack.addArrangedSubview(githubButton)
    card.addSubview(horizontalStack)

    NSLayoutConstraint.activate([
        card.widthAnchor.constraint(equalToConstant: 280),
        card.heightAnchor.constraint(equalToConstant: 70),

        horizontalStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 15),
        horizontalStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -15),
        horizontalStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 5),
        horizontalStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -5),

        profileImage.widthAnchor.constraint(equalToConstant: 50),
        profileImage.heightAnchor.constraint(equalToConstant: 50),

        githubButton.widthAnchor.constraint(equalToConstant: 35),
        githubButton.heightAnchor.constraint(equalToConstant: 35)
    ])

    return card
}
