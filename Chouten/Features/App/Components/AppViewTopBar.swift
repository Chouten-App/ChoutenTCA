//
//  AppViewTopBar.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import UIKit

 class AppViewTopBar: UIView {

     let blurView: UIView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     let wrapper: UIView = {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        return wrapper
    }()

     let label: UILabel = {
        let label = UILabel()
        label.text = "Discover"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

     let settingsImageWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     let settingsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pfp")
        imageView.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

     let interactionWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     weak var delegate: AppViewTopBarDelegate?

     init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override  init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

     required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(blurView)
        wrapper.addSubview(label)
        settingsImageWrapper.addSubview(settingsImage)
        wrapper.addSubview(settingsImageWrapper)
        addSubview(wrapper)
        addSubview(interactionWrapper)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSettingsPopover))
        interactionWrapper.isUserInteractionEnabled = true
        interactionWrapper.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wrapper.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width + 2),
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            wrapper.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),

            blurView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),

            label.centerYAnchor.constraint(equalTo: settingsImageWrapper.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),

            settingsImageWrapper.widthAnchor.constraint(equalToConstant: 32),
            settingsImageWrapper.heightAnchor.constraint(equalToConstant: 32),
            settingsImageWrapper.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            settingsImageWrapper.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),

            settingsImage.centerXAnchor.constraint(equalTo: settingsImageWrapper.centerXAnchor),
            settingsImage.centerYAnchor.constraint(equalTo: settingsImageWrapper.centerYAnchor),

            interactionWrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            interactionWrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            interactionWrapper.topAnchor.constraint(equalTo: topAnchor),
            interactionWrapper.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override  func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        blurView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        label.textColor = ThemeManager.shared.getColor(for: .fg)

        settingsImageWrapper.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        settingsImageWrapper.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        settingsImage.tintColor = ThemeManager.shared.getColor(for: .fg)
    }

    @objc private func showSettingsPopover() {
        delegate?.didTapButton()
        /*
        let settingsView = SettingsView() // Replace with your actual SettingsView
        let popoverController = settingsView.popoverPresentationController
        popoverController?.sourceView = self
        popoverController?.sourceRect = self.bounds
        popoverController?.permittedArrowDirections = .any
        popoverController?.delegate = self

        // Present the popover
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene

        if let viewController = windowScene?.windows.first(where: \.isKeyWindow)?.rootViewController {
            viewController.present(settingsView, animated: true, completion: nil)
        }*/
    }
}

extension AppViewTopBar: UIPopoverPresentationControllerDelegate {
     func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
