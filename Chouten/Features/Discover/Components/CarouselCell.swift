//
//  CarouselCell.swift
//  Discover
//
//  Created by Inumaki on 13.07.24.
//

import UIKit

class CarouselCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "CarouselCell"

    var data: DiscoverData? = nil

    let overlayView = UIView()
    let addButton = CircleButton(icon: "plus")

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let primaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Primary"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor.fg
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let secondaryLabel: UILabel = {
        let label       = UILabel()
        label.font      = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.fg
        label.alpha     = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label           = UILabel()
        label.font          = UIFont.systemFont(ofSize: 12)
        label.textColor     = UIColor.fg
        label.alpha         = 0.7
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let iconText: UILabel = {
        let label = UILabel()
        label.text = "Icon"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.fg
        label.alpha = 0.7
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let icon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = UIColor.red
        return image
    }()

    // swiftlint:disable implicitly_unwrapped_optional
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    // swiftlint:enable implicitly_unwrapped_optional

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.backgroundColor = ThemeManager.shared.getColor(for: .container)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        contentView.layer.borderWidth = 0.5
        contentView.clipsToBounds = true

        overlayView.addSubview(addButton)
        overlayView.addSubview(secondaryLabel)
        overlayView.addSubview(primaryLabel)
        overlayView.addSubview(iconText)
        overlayView.addSubview(icon)
        overlayView.addSubview(descriptionLabel)

        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)

        addButton.isUserInteractionEnabled = true
        addButton.onTap = {
            self.showErrorDisplay(message: "Unimplemented", description: "Adding Shows to a list has not been implemented yet.")
        }

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1

        // Add a UILongPressGestureRecognizer for long press
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.2

        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressGestureRecognizer)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            addButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            primaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            primaryLabel.trailingAnchor.constraint(equalTo: iconText.leadingAnchor, constant: -8),
            primaryLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -12),

            secondaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            secondaryLabel.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
            secondaryLabel.bottomAnchor.constraint(equalTo: primaryLabel.topAnchor, constant: 4),

            iconText.trailingAnchor.constraint(equalTo: icon.leadingAnchor, constant: -2),
            iconText.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -12),

            icon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            icon.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -12),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 15)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let sublayers = overlayView.layer.sublayers {
            for sublayer in sublayers where sublayer is CAGradientLayer {
                sublayer.removeFromSuperlayer()
            }
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            ThemeManager.shared.getColor(for: .container).cgColor,
            ThemeManager.shared.getColor(for: .container).withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds

        overlayView.layer.insertSublayer(gradientLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with data: DiscoverData) {
        self.data = data

        imageView.setAsyncImage(url: data.poster)

        primaryLabel.text = data.titles.primary
        secondaryLabel.text = data.titles.secondary
        descriptionLabel.text = data.sanitizedDescription
        iconText.text = data.indicator
    }
}

extension CarouselCell: UIGestureRecognizerDelegate {
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scenes.windows.first,
              let navController = window.rootViewController as? UINavigationController,
              let data else {
            return
        }

        /*
        let tempVC = InfoViewRefactor(url: data.url)

        navController.navigationBar.isHidden = true
        navController.pushViewController(tempVC, animated: true)
         */
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // Apply a scale transform when the user taps or holds the card
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        case .ended, .cancelled:
            // Reset the scale transform when the tap or hold is released
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        default:
            break
        }
    }

    // UIGestureRecognizerDelegate method to allow simultaneous recognition with other gestures
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Check if the other gesture is a pan gesture (likely the UIScrollView's pan gesture)
        if otherGestureRecognizer is UIPanGestureRecognizer {
            // If it's a pan gesture, prevent simultaneous recognition to avoid interference
            return false
        }
        // Otherwise, allow simultaneous recognition for other gestures
        return true
    }
}
