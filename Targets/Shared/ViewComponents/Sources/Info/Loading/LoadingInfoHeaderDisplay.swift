//
//  LoadingInfoHeaderDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 19.02.24.
//

import Architecture
import Nuke
import UIKit

public class LoadingInfoHeaderDisplay: UIView {

    var offsetY: Double

    public let view = UIView()
    let gradientView = UIView()
    let bannerImage = UIView()
    let detailsWrapper = UIView()
    let detailsView = UIStackView()
    let posterImage = UIView()
    let titlesStack = UIStackView()
    let secondaryTitle = UILabel()
    let primaryTitle = UIView()
    let statusLabel = UIView()
    let ratingLabel = UIView()

    // swiftlint:disable implicitly_unwrapped_optional
    var containerHeightConstraint: NSLayoutConstraint!
    public var bannerHeightConstraint: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    let gradientLayer = CAGradientLayer()

    private var gradientApplied = false

    override public init(frame: CGRect) {
        self.offsetY = 0.0
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        self.offsetY = 0.0
        super.init(coder: coder)
        configure()
    }

    public init(offsetY: Double) {
        self.offsetY = offsetY
        super.init(frame: .zero)
        configure()
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        gradientView.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        gradientView.alpha = 0.8
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        bannerImage.backgroundColor = ThemeManager.shared.getColor(for: .container)
        bannerImage.alpha = 0.8
        bannerImage.clipsToBounds = true
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerImage)

        view.addSubview(gradientView)

        detailsView.axis = .horizontal
        detailsView.spacing = 12
        detailsView.distribution = .fillProportionally
        detailsView.translatesAutoresizingMaskIntoConstraints = false

        detailsWrapper.translatesAutoresizingMaskIntoConstraints = false
        detailsWrapper.addSubview(detailsView)

        view.addSubview(detailsWrapper)

        // poster
        posterImage.backgroundColor = ThemeManager.shared.getColor(for: .container)
        posterImage.alpha = 0.6
        posterImage.clipsToBounds = true
        posterImage.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        posterImage.layer.borderWidth = 0.5
        posterImage.layer.cornerRadius = 12
        posterImage.translatesAutoresizingMaskIntoConstraints = false

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(posterImage)

        // titles
        titlesStack.axis = .vertical
        titlesStack.translatesAutoresizingMaskIntoConstraints = false

        secondaryTitle.backgroundColor = ThemeManager.shared.getColor(for: .container)
        secondaryTitle.alpha = 0.3
        secondaryTitle.clipsToBounds = true
        secondaryTitle.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        secondaryTitle.layer.borderWidth = 0.5
        secondaryTitle.layer.cornerRadius = 4
        secondaryTitle.translatesAutoresizingMaskIntoConstraints = false

        primaryTitle.backgroundColor = ThemeManager.shared.getColor(for: .container)
        primaryTitle.alpha = 0.6
        primaryTitle.clipsToBounds = true
        primaryTitle.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        primaryTitle.layer.borderWidth = 0.5
        primaryTitle.layer.cornerRadius = 4
        primaryTitle.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.backgroundColor = ThemeManager.shared.getColor(for: .container)
        statusLabel.alpha = 0.6
        statusLabel.clipsToBounds = true
        statusLabel.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        statusLabel.layer.borderWidth = 0.5
        statusLabel.layer.cornerRadius = 4
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.backgroundColor = ThemeManager.shared.getColor(for: .container)
        ratingLabel.alpha = 0.6
        ratingLabel.clipsToBounds = true
        ratingLabel.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        ratingLabel.layer.borderWidth = 0.5
        ratingLabel.layer.cornerRadius = 4
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(secondaryTitle)
        view.addSubview(primaryTitle)
        view.addSubview(statusLabel)
        view.addSubview(ratingLabel)

        // Add constraints to push ratingLabel to the trailing edge
        ratingLabel.setContentHuggingPriority(.required, for: .horizontal)
        ratingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailsView)

        addSubview(view)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            heightAnchor.constraint(equalTo: view.heightAnchor),

            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),

            bannerImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),

            gradientView.leadingAnchor.constraint(equalTo: bannerImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: bannerImage.trailingAnchor),
            gradientView.heightAnchor.constraint(equalTo: bannerImage.heightAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bannerImage.bottomAnchor),

            detailsWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            detailsWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            detailsWrapper.topAnchor.constraint(equalTo: view.topAnchor),
            detailsWrapper.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            detailsView.leadingAnchor.constraint(equalTo: detailsWrapper.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: detailsWrapper.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: detailsWrapper.bottomAnchor),

            posterImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            posterImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            posterImage.widthAnchor.constraint(equalToConstant: 130),
            posterImage.heightAnchor.constraint(equalToConstant: 190),

            secondaryTitle.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 12),
            secondaryTitle.widthAnchor.constraint(equalToConstant: 80),
            secondaryTitle.heightAnchor.constraint(equalToConstant: 16),
            secondaryTitle.bottomAnchor.constraint(equalTo: primaryTitle.topAnchor, constant: -6),

            primaryTitle.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 12),
            primaryTitle.widthAnchor.constraint(equalToConstant: 120),
            primaryTitle.heightAnchor.constraint(equalToConstant: 20),
            primaryTitle.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -24),

            statusLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            statusLabel.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 12),
            statusLabel.heightAnchor.constraint(equalToConstant: 14),
            statusLabel.widthAnchor.constraint(equalToConstant: 60),

            ratingLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ratingLabel.heightAnchor.constraint(equalToConstant: 14),
            ratingLabel.widthAnchor.constraint(equalToConstant: 30)
        ])

        containerHeightConstraint = view.heightAnchor.constraint(equalToConstant: 400)
        containerHeightConstraint.isActive = true
        bannerHeightConstraint = bannerImage.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -40)
        bannerHeightConstraint.isActive = true
    }
}
