//
//  SearchCell.swift
//  Search
//
//  Created by Inumaki on 13.07.24.
//

import Architecture
import Info
import SharedModels
import UIKit

class SearchCell: UICollectionViewCell {
    static let reuseIdentifier: String = "SearchCell"

    var data: SearchData? = nil

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let indicator: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let indicatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        indicator.addSubview(indicatorLabel)
        imageView.addSubview(indicator)

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, countLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stackView)

        stackView.setCustomSpacing(4, after: imageView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(tapGestureRecognizer)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),

            indicator.widthAnchor.constraint(equalTo: indicatorLabel.widthAnchor, constant: 16), // Add some padding if needed
            indicator.heightAnchor.constraint(equalTo: indicatorLabel.heightAnchor, constant: 8),
            indicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            indicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            indicatorLabel.trailingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: -8),
            indicatorLabel.topAnchor.constraint(equalTo: indicator.topAnchor, constant: 4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with data: SearchData) {
        self.data = data
        imageView.setAsyncImage(url: data.poster)

        indicatorLabel.text = data.indicator
        titleLabel.text = data.titles.primary
        // swiftlint:disable force_unwrapping
        countLabel.text = "\(data.current != nil ? String(data.current!) : "~")/\(data.total != nil ? String(data.total!) : "~")"
        // swiftlint:enable force_unwrapping

        if data.indicator.isEmpty {
            indicator.alpha = 0.0
        }
    }

    @objc func handleTap() {
        guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scenes.windows.first,
              let navController = window.rootViewController as? UINavigationController,
            let data else {
            return
        }

        let tempVC = InfoViewRefactor(url: data.url)

        navController.navigationBar.isHidden = true
        navController.pushViewController(tempVC, animated: true)
    }
}
