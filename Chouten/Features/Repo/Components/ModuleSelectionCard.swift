//
//  ModuleSelectionCard.swift
//  Repo
//
//  Created by Inumaki on 14.06.24.
//

import UIKit

class ModuleSelectionCard: UIView {
    let module: RepoModule
    let repoId: String
    var selected: Bool

    let modulePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = nil
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
        label.text = "Author • v1.0.0"
        label.font = .systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let statusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(
                .init(
                    font: .systemFont(ofSize: 12, weight: .bold)
                )
            )
        imageView.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let statusWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(_ module: RepoModule, id: String, selected: Bool) {
        self.module = module
        self.repoId = id
        self.selected = selected
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

        if let imageUrl = documentsDirectory?
            .appendingPathComponent("Repos")
            .appendingPathComponent(repoId)
            .appendingPathComponent("Modules")
            .appendingPathComponent(module.id)
            .appendingPathComponent("icon.png") {
            let imageData = try? Data(contentsOf: imageUrl)

            if let imageData {
                let image = UIImage(data: imageData)

                modulePicture.image = image
            }
        }

        statusImage.alpha = selected ? 1.0 : 0.0
        statusWrapper.backgroundColor = selected ? ThemeManager.shared.getColor(for: .accent) : .clear

        statusWrapper.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        statusWrapper.layer.borderWidth = selected ? 0.0 : 2

        title.text = module.name
        subtitle.text = "\(module.author) • \(module.version)"

        addSubview(modulePicture)
        addSubview(title)
        addSubview(subtitle)

        statusWrapper.addSubview(statusImage)
        addSubview(statusWrapper)

        alpha = selected ? 1.0 : 0.7
    }

    private func setupConstraints() {

//        let heightConstraint = heightAnchor
//                        .constraint(equalToConstant: 80)
//        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

            modulePicture.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            modulePicture.centerYAnchor.constraint(equalTo: centerYAnchor),
            modulePicture.widthAnchor.constraint(equalToConstant: 44),
            modulePicture.heightAnchor.constraint(equalToConstant: 44),

            title.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: modulePicture.trailingAnchor, constant: 8),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: modulePicture.trailingAnchor, constant: 8),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            statusImage.widthAnchor.constraint(equalToConstant: 10),
            statusImage.heightAnchor.constraint(equalToConstant: 10),
            statusImage.centerXAnchor.constraint(equalTo: statusWrapper.centerXAnchor),
            statusImage.centerYAnchor.constraint(equalTo: statusWrapper.centerYAnchor),

            statusWrapper.widthAnchor.constraint(equalToConstant: 24),
            statusWrapper.heightAnchor.constraint(equalToConstant: 24),
            statusWrapper.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusWrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func reload() {
        alpha = selected ? 1.0 : 0.7
        statusImage.alpha = selected ? 1.0 : 0.0
        statusWrapper.backgroundColor = selected ? ThemeManager.shared.getColor(for: .accent) : .clear
        statusWrapper.layer.borderWidth = selected ? 0.0 : 2
    }
}
