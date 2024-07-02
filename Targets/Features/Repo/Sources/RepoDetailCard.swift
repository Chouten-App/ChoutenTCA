//
//  RepoDetailCard.swift
//  Repo
//
//  Created by Inumaki on 10.06.24.
//

import Architecture
import SharedModels
import UIKit

class RepoDetailCard: UIView {

    let repo: RepoMetadata

    let repoPicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pfp")
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let title: UILabel = {
        let label = UILabel()
        label.text = "Repo Title"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitle: UILabel = {
        let label = UILabel()
        label.text = "Author • https://localhost:5500"
        label.font = .systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(_ repo: RepoMetadata) {
        self.repo = repo
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = ThemeManager.shared.getColor(for: .container)
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false

        // set data
        // Get the path to the user's Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let imageUrl = documentsDirectory?.appendingPathComponent("Repos").appendingPathComponent(repo.id).appendingPathComponent("icon.png") {
            let imageData = try? Data(contentsOf: imageUrl)

            if let imageData {
                let image = UIImage(data: imageData)

                repoPicture.image = image
            }
        }

        title.text = repo.title
        subtitle.text = "\(repo.author) • \(repo.url ?? "")"

        addSubview(repoPicture)
        addSubview(title)
        addSubview(subtitle)
    }

    private func setupConstraints() {

//        let heightConstraint = heightAnchor
//                        .constraint(equalToConstant: 80)
//        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

            repoPicture.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            repoPicture.centerYAnchor.constraint(equalTo: centerYAnchor),
            repoPicture.widthAnchor.constraint(equalToConstant: 44),
            repoPicture.heightAnchor.constraint(equalToConstant: 44),

            title.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: repoPicture.trailingAnchor, constant: 8),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: repoPicture.trailingAnchor, constant: 8),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
