//
//  InfoHeaderDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 31.01.24.
//

import Architecture
import Nuke
import SharedModels
import UIKit

public class InfoHeaderDisplay: UIView {

    public var infoData: InfoData
    var offsetY: Double

    public let view = UIView()
    let gradientView = UIView()
    let bannerImage = UIImageView()
    let detailsWrapper = UIView()
    let detailsView = UIStackView()
    let posterImage = UIImageView()
    let titlesStack = UIStackView()
    let secondaryTitle = UILabel()
    let primaryTitle = UILabel()
    let statusLabel = UILabel()
    let ratingLabel = UILabel()
    
    public let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal) // Use the bookmark icon
        button.tintColor = ThemeManager.shared.getColor(for: .accent) // Adjust color as needed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // swiftlint:disable implicitly_unwrapped_optional
    var containerHeightConstraint: NSLayoutConstraint!
    public var bannerHeightConstraint: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    let gradientLayer = CAGradientLayer()

    private var gradientApplied = false

    override public init(frame: CGRect) {
        self.infoData = .sample
        self.offsetY = 0.0
        super.init(frame: frame)
        configure()
    }

    public required init?(coder: NSCoder) {
        self.infoData = .sample
        self.offsetY = 0.0
        super.init(coder: coder)
        configure()
    }

    public init(infoData: InfoData, offsetY: Double) {
        self.infoData = infoData
        self.offsetY = offsetY
        super.init(frame: .zero)
        configure()
    }

    public func updateData() {
        var imageUrlString = infoData.banner ?? infoData.poster

        if imageUrlString.isEmpty {
            imageUrlString = infoData.poster
        }

        self.bannerImage.setAsyncImage(url: imageUrlString)

        let posterUrlString = infoData.poster
        self.posterImage.setAsyncImage(url: posterUrlString)

        secondaryTitle.text = infoData.titles.secondary ?? "N/A"

        primaryTitle.text = infoData.titles.primary

        statusLabel.text = infoData.status ?? "N/A"

        ratingLabel.text = "\(infoData.yearReleased)"
    }

    public func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        gradientView.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        gradientView.alpha = 0.8
        gradientView.translatesAutoresizingMaskIntoConstraints = false

        bannerImage.contentMode = .scaleAspectFill
        bannerImage.clipsToBounds = true
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerImage)

        var imageUrlString = infoData.banner ?? infoData.poster

        if imageUrlString.isEmpty {
            imageUrlString = infoData.poster
        }
        self.bannerImage.setAsyncImage(url: imageUrlString)

        view.addSubview(gradientView)

        detailsView.axis = .horizontal
        detailsView.spacing = 12
        detailsView.distribution = .fillProportionally
        detailsView.translatesAutoresizingMaskIntoConstraints = false

        detailsWrapper.translatesAutoresizingMaskIntoConstraints = false
        detailsWrapper.addSubview(detailsView)

        view.addSubview(detailsWrapper)

        // poster
        posterImage.contentMode = .scaleAspectFill
        posterImage.clipsToBounds = true
        posterImage.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        posterImage.layer.borderWidth = 0.5
        posterImage.layer.cornerRadius = 12
        posterImage.translatesAutoresizingMaskIntoConstraints = false

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false

        detailsView.addArrangedSubview(posterImage)

        let posterUrlString = infoData.poster
        self.posterImage.setAsyncImage(url: posterUrlString)

        // titles
        titlesStack.axis = .vertical
        titlesStack.translatesAutoresizingMaskIntoConstraints = false

        secondaryTitle.text = infoData.titles.secondary ?? "N/A"
        secondaryTitle.textColor = ThemeManager.shared.getColor(for: .fg)
        secondaryTitle.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        secondaryTitle.alpha = 0.7

        primaryTitle.text = infoData.titles.primary
        primaryTitle.textColor = ThemeManager.shared.getColor(for: .fg)
        primaryTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        primaryTitle.numberOfLines = 2

        statusLabel.text = infoData.status ?? "N/A"
        statusLabel.textColor = ThemeManager.shared.getColor(for: .accent)
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)

        ratingLabel.text = "10.0"
        ratingLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        ratingLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        ratingLabel.numberOfLines = 0

        let statusSpacer = UIView()
        statusSpacer.translatesAutoresizingMaskIntoConstraints = false

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .bottom
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        let horizontalTitlesStack = UIStackView()
        horizontalTitlesStack.axis = .horizontal
        horizontalTitlesStack.alignment = .bottom
        horizontalTitlesStack.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(bookmarkButton)
        horizontalTitlesStack.addArrangedSubview(statusLabel)
        horizontalTitlesStack.addArrangedSubview(ratingLabel)

        titlesStack.addArrangedSubview(spacer)
        titlesStack.addArrangedSubview(secondaryTitle)
        titlesStack.addArrangedSubview(primaryTitle)
        titlesStack.addArrangedSubview(statusSpacer)
        titlesStack.addArrangedSubview(horizontalTitlesStack)

        horizontalStack.addArrangedSubview(titlesStack)
        
        bookmarkButton.translatesAutoresizingMaskIntoConstraints = false

        // Add constraints to push ratingLabel to the trailing edge
        ratingLabel.setContentHuggingPriority(.required, for: .horizontal)
        ratingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        detailsView.addArrangedSubview(horizontalStack)

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

            posterImage.widthAnchor.constraint(equalToConstant: 130),
            posterImage.heightAnchor.constraint(equalToConstant: 190),

            horizontalStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            statusSpacer.heightAnchor.constraint(equalToConstant: 20),
            
            bookmarkButton.widthAnchor.constraint(equalToConstant: 24),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 24)
        ])

        containerHeightConstraint = view.heightAnchor.constraint(equalToConstant: 400)
        containerHeightConstraint.isActive = true
        bannerHeightConstraint = bannerImage.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -40)
        bannerHeightConstraint.isActive = true

        gradientLayer.colors = [UIColor.bg.withAlphaComponent(0.9).cgColor, UIColor.bg.withAlphaComponent(0.6).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 360)
    }
}
