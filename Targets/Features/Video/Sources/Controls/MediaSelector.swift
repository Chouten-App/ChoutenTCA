//
//  MediaSelector.swift
//  Video
//
//  Created by Inumaki on 08.07.24.
//

import Architecture
import SharedModels
import UIKit
import ViewComponents

class MediaSelectorItem: UIView {

    let item: MediaItem
    let fallbackImageUrl: String

    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 1
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(_ item: MediaItem, fallbackImageUrl: String) {
        self.item = item
        self.fallbackImageUrl = fallbackImageUrl
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.shared.getColor(for: .container)
        layer.cornerRadius = 12
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        clipsToBounds = true

        addSubview(imageView)
        self.imageView.setAsyncImage(url: item.thumbnail ?? fallbackImageUrl)
        addSubview(gradientView)
        gradientView.addSubview(titleLabel)

        addSubview(subtitleLabel)

        titleLabel.text = item.title
        subtitleLabel.text = "Episode \(item.number.removeTrailingZeros())"
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 280),

            imageView.widthAnchor.constraint(equalToConstant: 280),
            imageView.heightAnchor.constraint(equalToConstant: 280 / 16 * 9),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),

            gradientView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: imageView.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            subtitleLabel.topAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: 6)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            ThemeManager.shared.getColor(for: .container).cgColor,
            ThemeManager.shared.getColor(for: .container).withAlphaComponent(0.9).cgColor,
            ThemeManager.shared.getColor(for: .container).withAlphaComponent(0.6).cgColor,
            ThemeManager.shared.getColor(for: .container).withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [
            0,
            0.5,
            0.75,
            1
        ]
        gradientLayer.frame = bounds

        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

class MediaSelector: UIView {

    let mediaList: [MediaList]
    let fallbackImageUrl: String

    let blurView: UIVisualEffectView = {
        let effect              = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view                = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let seasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Season 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let mediaCountLabel: UILabel = {
        let label = UILabel()
        label.text = "12 Episodes"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 14)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let seasonButton = CircleButton(icon: "chevron.down")

    public let closeButton = CircleButton(icon: "xmark")

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let mediaStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(mediaList: [MediaList], fallbackImageUrl: String) {
        self.mediaList = mediaList
        self.fallbackImageUrl = fallbackImageUrl
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override init(frame: CGRect) {
        self.mediaList = []
        self.fallbackImageUrl = ""
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        scrollView.addSubview(mediaStack)
        addSubview(scrollView)

        addSubview(seasonTitleLabel)
        addSubview(seasonButton)
        addSubview(mediaCountLabel)
        addSubview(closeButton)

        if let list = mediaList.first?.pagination.first?.items {
            for index in 0..<list.count {
                let item = MediaSelectorItem(list[index], fallbackImageUrl: fallbackImageUrl)
                mediaStack.addArrangedSubview(item)
            }
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            seasonTitleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            seasonTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            seasonButton.leadingAnchor.constraint(equalTo: seasonTitleLabel.trailingAnchor, constant: 12),
            seasonButton.centerYAnchor.constraint(equalTo: seasonTitleLabel.centerYAnchor),

            mediaCountLabel.leadingAnchor.constraint(equalTo: seasonTitleLabel.leadingAnchor),
            mediaCountLabel.topAnchor.constraint(equalTo: seasonTitleLabel.bottomAnchor, constant: 2),

            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 30),

            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            mediaStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            mediaStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            mediaStack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
    }
}
