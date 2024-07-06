//
//  SettingsView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Architecture
import Combine
import ComposableArchitecture
import RelayClient
import SharedModels
import UIKit
import ViewComponents

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            // swiftlint:disable force_unwrapping
            parentResponder = parentResponder!.next
            // swiftlint:enable force_unwrapping
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class TopBar: UIView {
    // MARK: - Properties
    private let effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0.0
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()

    private let doneText: UILabel = {
        let label = UILabel()
        label.text = "Done"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let settingsText: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false

        addSubview(effectView)
        sendSubviewToBack(effectView)

        addSubview(doneText)
        addSubview(settingsText)

        NSLayoutConstraint.activate([
            doneText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            doneText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),

            settingsText.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            settingsText.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),

            effectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            effectView.topAnchor.constraint(equalTo: self.topAnchor),
            effectView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        doneText.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        doneText.addGestureRecognizer(tapGesture)
    }

    // MARK: - Configuration
    func configure(settingsText: String, doneText: String) {
        self.settingsText.text = settingsText
        self.doneText.text = doneText
    }

    func updateAppearance() {
        doneText.textColor = ThemeManager.shared.getColor(for: .fg)
        settingsText.textColor = ThemeManager.shared.getColor(for: .fg)
    }

    @objc func handleTap() {
        if doneText.text == "Done" {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.dismiss(animated: true)
            }
        } else {
            // remove other view and vc like appearance or logs
            if let parentVC = self.parentViewController {
                if let childVC = parentVC.children.first(where: { $0.view.tag == 1000 }) {
                    UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                        childVC.view.alpha = 0.0
                        childVC.view.transform = CGAffineTransform(translationX: 0, y: parentVC.view.frame.height)
                    }) { _ in
                        childVC.view.removeFromSuperview()
                        childVC.removeFromParent()
                        if let settingsVC = parentVC as? SettingsView {
                            settingsVC.topbar.configure(settingsText: "Settings", doneText: "Done")
                        }
                    }
                }
            }
        }
    }
}

public class SettingsView: UIViewController {
//    var store: Store<SettingsFeature.State, SettingsFeature.Action>

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let madeByLabel: UILabel = {
        let label = UILabel()
        let text = "Made by Inumaki with ❤️"
        label.text = text
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 0.4.0"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 12)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: ProfileCard
    /*let profileCard: UIView = {
        let card = UIView()
        card.backgroundColor = ThemeManager.shared.getColor(for: .container)
        card.layer.cornerRadius = 20
        card.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        card.layer.borderWidth = 0.5
        card.translatesAutoresizingMaskIntoConstraints = false

        // horizontal stack
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 12
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false

        // profile image
        let profileImage = UIImageView(image: UIImage(named: "pfp"))
        profileImage.contentMode = .scaleToFill
        profileImage.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.cornerRadius = 8
        profileImage.clipsToBounds = true

        // stack for texts
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 0
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text = "Inumaki"
        nameLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // icon stack
        let iconStack = UIStackView()
        iconStack.axis = .horizontal
        iconStack.spacing = 4
        iconStack.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "person.badge.shield.checkmark.fill")?.withRenderingMode(.alwaysTemplate))
        icon.tintColor = ThemeManager.shared.getColor(for: .accent)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Developer"
        subtitleLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.alpha = 0.7
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        horizontalStack.addArrangedSubview(profileImage)
        horizontalStack.addArrangedSubview(textStack)

        textStack.addArrangedSubview(nameLabel)

        iconStack.addArrangedSubview(icon)
        iconStack.addArrangedSubview(subtitleLabel)

        textStack.addArrangedSubview(iconStack)
        card.addSubview(horizontalStack)

        NSLayoutConstraint.activate([
            horizontalStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            horizontalStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            horizontalStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            horizontalStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            profileImage.widthAnchor.constraint(equalToConstant: 64),
            profileImage.heightAnchor.constraint(equalToConstant: 64),

            iconStack.heightAnchor.constraint(equalToConstant: 16),

            textStack.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: -10),

            icon.widthAnchor.constraint(equalToConstant: 16),

            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])

        return card
    }()*/

    let notLoggedInView: UIView = {
        let card = UIView()
        card.backgroundColor = ThemeManager.shared.getColor(for: .container)
        card.layer.cornerRadius = 20
        card.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        card.layer.borderWidth = 0.5
        card.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Not logged in."
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = ThemeManager.shared.getColor(for: .fg)

        let description = UILabel()
        description.text = "Logging in is currently unsupported. We hope to bring Discord login or something similar fairly soon."
        description.numberOfLines = 0
        description.textAlignment = .center
        description.font = .systemFont(ofSize: 12)
        description.textColor = ThemeManager.shared.getColor(for: .fg)
        description.alpha = 0.7

        let note = UILabel()
        note.text = "Note: This login is unrelated to tracking."
        note.font = .systemFont(ofSize: 10)
        note.textColor = ThemeManager.shared.getColor(for: .fg)
        note.alpha = 0.7

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(description)
        stack.addArrangedSubview(note)

        card.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        return card
    }()

    let settingDisplay: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.cornerRadius = 20
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false

        let iconView = CircleButton(icon: "sun.max.fill")
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Appearance"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false

        let chevronView = UIImageView()
        chevronView.image = UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(
                .init(
                    font: .systemFont(ofSize: 14)
                )
            )
        chevronView.tintColor = ThemeManager.shared.getColor(for: .fg)
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(iconView)
        view.addSubview(label)
        view.addSubview(chevronView)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            iconView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),

            chevronView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])

        return view
    }()

    let logDisplay: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.cornerRadius = 20
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false

        let iconView = CircleButton(icon: "laptopcomputer")
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Developer"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false

        let chevronView = UIImageView()
        chevronView.image = UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(
                .init(
                    font: .systemFont(ofSize: 14)
                )
            )
        chevronView.tintColor = ThemeManager.shared.getColor(for: .fg)
        chevronView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(iconView)
        view.addSubview(label)
        view.addSubview(chevronView)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            iconView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            label.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),

            chevronView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12)
        ])

        return view
    }()

    let topbar = TopBar()

    let navController = UINavigationController()

    public init() {
//        store = .init(
//            initialState: .init(),
//            reducer: { SettingsFeature() }
//        )
        super.init(nibName: nil, bundle: nil)

//        store.send(.view(.onAppear))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        labelStack.addArrangedSubview(madeByLabel)
        labelStack.addArrangedSubview(versionLabel)

        stack.addArrangedSubview(notLoggedInView)
        stack.addArrangedSubview(settingDisplay)
        stack.addArrangedSubview(logDisplay)
        stack.addArrangedSubview(labelStack)

        view.addSubview(stack)
        view.addSubview(topbar)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 72),
            topbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topbar.heightAnchor.constraint(equalToConstant: 52)
        ])

        view.bringSubviewToFront(topbar)
        topbar.layer.zPosition = 100

        settingDisplay.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToAppearance))
        settingDisplay.addGestureRecognizer(tapGesture)

        logDisplay.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(goToLog))
        logDisplay.addGestureRecognizer(tapGesture2)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        self.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        topbar.updateAppearance()
    }

    @objc func goToAppearance() {
        let tempVC = AppearanceVC()

        tempVC.view.tag = 1000

        addChild(tempVC)
        view.addSubview(tempVC.view)
        topbar.configure(settingsText: "Appearance", doneText: "Back")

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            tempVC.view.alpha = 1.0
            tempVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }

        // navController.pushViewController(tempVC, animated: true)
    }

    @objc func goToLog() {
        let tempVC = LogVC()

        tempVC.view.tag = 1000

        addChild(tempVC)
        view.addSubview(tempVC.view)
        topbar.configure(settingsText: "Developer", doneText: "Back")

        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) {
            tempVC.view.alpha = 1.0
            tempVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
}
