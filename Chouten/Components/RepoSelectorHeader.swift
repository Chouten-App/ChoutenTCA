//
//  RepoSelectorHeader.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.03.24.
//

import UIKit

class RepoSelectorHeader: UIView {

    let repo: RepoMetadata

    let wrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14)
        label.alpha = 0.7
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Repo Name"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let authorLabel: UILabel = {
        let label = UILabel()
        label.text = "Author"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let repoPicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pfp")
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "v1.0.0"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let versionWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 12
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(_ repo: RepoMetadata) {
        self.repo = repo
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override init(frame: CGRect) {
        self.repo = RepoMetadata(id: "", title: "", author: "", description: "", modules: [])
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        authorLabel.text = repo.author
        titleLabel.text = repo.title
        descriptionLabel.text = repo.description

        addSubview(wrapper)

        wrapper.addSubview(repoPicture)
        wrapper.addSubview(titleLabel)
        wrapper.addSubview(authorLabel)
        wrapper.addSubview(descriptionLabel)

        wrapper.addSubview(versionWrapper)
        versionWrapper.addSubview(versionLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            wrapper.topAnchor.constraint(equalTo: topAnchor),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),

            repoPicture.widthAnchor.constraint(equalToConstant: 64),
            repoPicture.heightAnchor.constraint(equalToConstant: 64),
            repoPicture.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 16),
            repoPicture.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),

            titleLabel.leadingAnchor.constraint(equalTo: repoPicture.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: repoPicture.topAnchor, constant: 12),

            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            descriptionLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),
            descriptionLabel.topAnchor.constraint(equalTo: repoPicture.bottomAnchor, constant: 8),

            versionWrapper.widthAnchor.constraint(equalToConstant: versionLabel.intrinsicContentSize.width + 12),
            versionWrapper.heightAnchor.constraint(equalToConstant: versionLabel.intrinsicContentSize.height + 8),
            versionWrapper.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -16),
            versionWrapper.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),

            versionLabel.centerXAnchor.constraint(equalTo: versionWrapper.centerXAnchor),
            versionLabel.centerYAnchor.constraint(equalTo: versionWrapper.centerYAnchor)
        ])
    }
}
