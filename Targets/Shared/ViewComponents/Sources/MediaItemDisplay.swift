//
//  MediaItemDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 03.02.24.
//

import Architecture
import Nuke
import SharedModels
import UIKit

class MediaItemDisplay: UIView {

    var mediaItem: MediaItem
    let index: Int
    var watched: Bool

    // swiftlint:disable lower_acl_than_parent
    public weak var delegate: MediaItemDelegate?
    // swiftlint:enable lower_acl_than_parent

    override init(frame: CGRect) {
        self.mediaItem = MediaItem.sample
        self.index = 0
        self.watched = false
        super.init(frame: frame)
        configure()
        setConstraints()
    }

    required init?(coder: NSCoder) {
        self.mediaItem = MediaItem.sample
        self.index = 0
        self.watched = false
        super.init(coder: coder)
        configure()
        setConstraints()
    }

    init(item: MediaItem, index: Int, watched: Bool = false) {
        self.mediaItem = item
        self.index = index
        self.watched = watched
        super.init(frame: .zero)
        configure()
        setConstraints()
    }

    let mainView = UIView()

    let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Episode 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.alpha = 0.7
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let imageView = UIImageView()

    let indicatorLabel: UILabel = {
        let label = UILabel()
        label.text = "🇬🇧"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let indicatorWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private func configure() {
        mainView.backgroundColor = ThemeManager.shared.getColor(for: .container)
        mainView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        mainView.layer.borderWidth = 0.5
        mainView.layer.cornerRadius = 12

        mainView.translatesAutoresizingMaskIntoConstraints = false

        mainStack.addArrangedSubview(horizontalStack)
        if mediaItem.description != nil {
            mainStack.addArrangedSubview(descriptionLabel)
        }

        mainView.addSubview(mainStack)

        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(subtitleLabel)

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = ThemeManager.shared.getColor(for: .overlay)

        if let image = mediaItem.thumbnail {
            let posterUrlString = image
            self.imageView.setAsyncImage(url: posterUrlString)

            horizontalStack.addArrangedSubview(imageView)
        }
        horizontalStack.addArrangedSubview(verticalStack)

        // set data
        titleLabel.text = mediaItem.title ?? "Episode \(mediaItem.number.removeTrailingZeros())"
        subtitleLabel.text = "Episode \(mediaItem.number.removeTrailingZeros())"
        descriptionLabel.text = mediaItem.description
        indicatorLabel.text = mediaItem.language

        indicatorWrapper.addSubview(indicatorLabel)
        if mediaItem.language != nil {
            mainView.addSubview(indicatorWrapper)
        }

        addSubview(mainView)

        indicatorWrapper.layer.cornerRadius = (indicatorLabel.intrinsicContentSize.height + 4) / 2

        let onTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(onTap)

        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.2
        self.addGestureRecognizer(longPressGestureRecognizer)

        self.alpha = watched ? 0.5 : 1.0
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            mainView.widthAnchor.constraint(equalTo: widthAnchor),
            mainView.heightAnchor.constraint(equalTo: heightAnchor),

            mainStack.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -16 - (indicatorLabel.intrinsicContentSize.width + 12)),
            mainStack.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -12),

            horizontalStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            horizontalStack.topAnchor.constraint(equalTo: mainStack.topAnchor),

            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 64 / 9 * 16),

            verticalStack.trailingAnchor.constraint(equalTo: horizontalStack.trailingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor)
        ])

        if mediaItem.language != nil {
            NSLayoutConstraint.activate([
                indicatorWrapper.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8),
                indicatorWrapper.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8),

                indicatorLabel.trailingAnchor.constraint(equalTo: indicatorWrapper.trailingAnchor, constant: -6),
                indicatorLabel.leadingAnchor.constraint(equalTo: indicatorWrapper.leadingAnchor, constant: 6),
                indicatorLabel.topAnchor.constraint(equalTo: indicatorWrapper.topAnchor, constant: 2),
                indicatorLabel.bottomAnchor.constraint(equalTo: indicatorWrapper.bottomAnchor, constant: -2)
            ])
        }

        if mediaItem.description != nil {
            NSLayoutConstraint.activate([
                descriptionLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40 - 32),
                descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
                descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ])
        }
    }

    @objc func handleTap() {
        self.delegate?.tapped(mediaItem, index: index)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // Set the watched property and update the database immediately
            self.watched = true
            self.mediaItem.isWatched = true
            DatabaseManager.shared.updateMediaItem(self.mediaItem)

            // Perform the animation
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.5
            }
        case .changed:
            // Perform the animation
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.5
            }
        case .ended, .cancelled:
            break
        default:
            break
        }
    }

}
