//
//  ErrorDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 13.02.24.
//

import Architecture
import UIKit

extension UIView {
    func showErrorDisplay(message: String, description: String? = nil) {
        // Access the window scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        // Create and configure the ErrorDisplay view
        let errorDisplay = ErrorDisplay()
        errorDisplay.titleLabel.text = message

        if let description = description {
            errorDisplay.descriptionLabel.text = description
        }

        // Add the ErrorDisplay view to the window
        window.addSubview(errorDisplay)

        // Configure the initial position
        errorDisplay.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = errorDisplay.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: 100)
        bottomConstraint.isActive = true

        errorDisplay.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
        errorDisplay.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true

        window.layoutIfNeeded()

        // Animate the ErrorDisplay view to slide up with a spring animation
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            bottomConstraint.constant = -20
            window.layoutIfNeeded()
        }, completion: nil)

        // Delay removal and animate out after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Animate the ErrorDisplay view to slide down with a spring animation
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: {
                    bottomConstraint.constant = 100
                    window.layoutIfNeeded()
                },
                completion: { _ in
                    // Remove the ErrorDisplay view from the window after animation completes
                    errorDisplay.removeFromSuperview()
                }
            )
        }

        var scale: CGFloat = 1.0
        for subview in window.subviews.reversed() {
            if let existingErrorDisplay = subview as? ErrorDisplay, existingErrorDisplay != errorDisplay {
                scale *= 0.95 // Adjust the scale factor as needed
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseInOut,
                    animations: {
                        existingErrorDisplay.transform = CGAffineTransform(scaleX: scale, y: scale)
                        existingErrorDisplay.center.y -= 16
                        window.layoutIfNeeded()
                    }
                )
            }
        }
    }
}

class ErrorDisplay: UIView {

    let view: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.cornerRadius = 20
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let indicator: UILabel = {
        let label = UILabel()
        label.text = "System"
        label.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 12
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Error:"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Example Error"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.numberOfLines = 3
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {

        indicatorView.addSubview(indicator)
        view.addSubview(typeLabel)
        view.addSubview(titleLabel)
        view.addSubview(indicatorView)
        view.addSubview(descriptionLabel)

        addSubview(view)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),

            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor),

            typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            typeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            titleLabel.centerYAnchor.constraint(equalTo: typeLabel.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: typeLabel.trailingAnchor, constant: 4),

            descriptionLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            descriptionLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: indicatorView.trailingAnchor),

            indicatorView.widthAnchor.constraint(equalToConstant: indicator.intrinsicContentSize.width + 18),
            indicatorView.heightAnchor.constraint(equalToConstant: 22),
            indicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            indicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            indicator.centerYAnchor.constraint(equalTo: indicatorView.centerYAnchor),
            indicator.centerXAnchor.constraint(equalTo: indicatorView.centerXAnchor)
        ])
    }
}
