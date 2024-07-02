//
//  CarouselCard.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 29.01.24.
//

import Architecture
import Nuke
import SharedModels
import UIKit

// swiftlint:disable type_body_length
public class CarouselCard: UIView, UIGestureRecognizerDelegate {
    public let mainView = UIView()
    public let imageView = UIImageView()
    public let overlayView = UIView()

    public let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public let titlesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public let topStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .bottom
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public let detailsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()

    public let spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let spacerHorizontalView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let buttonSpacer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let primaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Primary"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor.fg
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let iconText: UILabel = {
        let label = UILabel()
        label.text = "Icon"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.fg
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let secondaryLabel: UILabel = {
        let label       = UILabel()
        label.text      = "Secondary"
        label.font      = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.fg
        label.alpha     = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let descriptionLabel: UILabel = {
        let label           = UILabel()
        label.text          = ""
        label.font          = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor     = UIColor.fg
        label.alpha         = 0.7
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let icon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = UIColor.red
        return image
    }()

    public let plusButton = PlusButton()
    public let gradientLayer = CAGradientLayer()
    public let data: DiscoverData

    public weak var delegate: CarouselCardDelegate?

    override public init(frame: CGRect) {
        data = DiscoverSection.sampleSection.list[0]
        super.init(frame: frame)
        configure()
        setConstraints()
        updateData()
    }

    public required init?(coder: NSCoder) {
        data = DiscoverSection.sampleSection.list[0]
        super.init(coder: coder)
        configure()
        setConstraints()
        updateData()
    }

    override public func layoutSubviews() {
        stack.setGradientBackground(
            colorTop: ThemeManager.shared.getColor(for: .container)
                            .withAlphaComponent(0.0),
            colorBottom: ThemeManager.shared.getColor(for: .container)
        )
    }

    public init(data: DiscoverData) {
        self.data = data
        super.init(frame: .zero)
        configure()
        setConstraints()
        updateData()
    }

    // swiftlint:disable implicitly_unwrapped_optional
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    // swiftlint:enable implicitly_unwrapped_optional

    private func configure() {
        // Add a UITapGestureRecognizer for tap
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)

        // Add a UILongPressGestureRecognizer for long press
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.2
        addGestureRecognizer(longPressGestureRecognizer)

        mainView.backgroundColor = UIColor.itemBG
        mainView.layer.cornerRadius = 12
        mainView.clipsToBounds = true
        mainView.layer.borderWidth = 0.5
        mainView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        mainView.translatesAutoresizingMaskIntoConstraints = false

        // image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(imageView)  // Add the imageView to mainView

        // Set Nuke image loading
        let imageUrlString = data.poster
        self.imageView.setAsyncImage(url: imageUrlString)

        // text stack
        stack.addArrangedSubview(detailsStack)

        topStack.addArrangedSubview(titlesStack)
        topStack.addArrangedSubview(spacerHorizontalView)
        topStack.addArrangedSubview(iconText)
        topStack.addArrangedSubview(icon)

        titlesStack.addArrangedSubview(secondaryLabel)
        titlesStack.addArrangedSubview(primaryLabel)

        plusButton.tintColor = ThemeManager.shared.getColor(for: .fg)

        buttonStack.addArrangedSubview(buttonSpacer)
        buttonStack.addArrangedSubview(plusButton)

        detailsStack.addArrangedSubview(buttonStack)
        detailsStack.addArrangedSubview(spacerView)
        detailsStack.addArrangedSubview(topStack)
        detailsStack.addArrangedSubview(descriptionLabel)
        mainView.addSubview(stack)

        addSubview(mainView)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 440),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),

            imageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: mainView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: mainView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),

            detailsStack.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
            detailsStack.widthAnchor.constraint(equalTo: stack.widthAnchor),
            detailsStack.heightAnchor.constraint(equalTo: stack.heightAnchor),

            secondaryLabel.heightAnchor.constraint(equalToConstant: 16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 44),

            iconText.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -8),
            // iconText.bottomAnchor.constraint(equalTo: topStack.bottomAnchor, constant: -4),

            icon.trailingAnchor.constraint(equalTo: detailsStack.trailingAnchor, constant: -16),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 15),
            icon.centerYAnchor.constraint(equalTo: iconText.centerYAnchor),

            plusButton.trailingAnchor.constraint(equalTo: detailsStack.trailingAnchor, constant: -16)
        ])
    }

    private func updateData() {
        secondaryLabel.text = data.titles.secondary ?? "N/A"
        primaryLabel.text = data.titles.primary
        descriptionLabel.text = data.description
        iconText.text = data.indicator
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        stack.setGradientBackground(
            colorTop: ThemeManager.shared.getColor(for: .container)
                            .withAlphaComponent(0.0),
            colorBottom: ThemeManager.shared.getColor(for: .container)
        )
        mainView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        secondaryLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        primaryLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        descriptionLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        iconText.textColor = ThemeManager.shared.getColor(for: .fg)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.carouselCardDidTap(data)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // Apply a scale transform when the user taps or holds the card
            UIView.animate(withDuration: 0.2) {
                self.mainView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        case .ended, .cancelled:
            // Reset the scale transform when the tap or hold is released
            UIView.animate(withDuration: 0.2) {
                self.mainView.transform = .identity
            }
        default:
            break
        }
    }

    // UIGestureRecognizerDelegate method to allow simultaneous recognition with other gestures
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Check if the other gesture is a pan gesture (likely the UIScrollView's pan gesture)
        if otherGestureRecognizer is UIPanGestureRecognizer {
            // If it's a pan gesture, prevent simultaneous recognition to avoid interference
            return false
        }
        // Otherwise, allow simultaneous recognition for other gestures
        return true
    }
}
// swiftlint:enable type_body_length
