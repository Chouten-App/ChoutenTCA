//
//  ClearButton.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import UIKit

public class SearchHeader: UIView {

    public let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.0
        return view
    }()

    let wrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let backButton = CircleButton(icon: "chevron.left")

    let textFieldWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let textField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: "Search for something...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.fg.withAlphaComponent(0.5)]
        )
        field.font = .systemFont(ofSize: 14)
        field.textColor = ThemeManager.shared.getColor(for: .fg)
        field.tintColor = ThemeManager.shared.getColor(for: .accent)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    public let clearButton = ClearButton()

    public init() {
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
        addSubview(wrapper)
        wrapper.addSubview(blurView)
        wrapper.addSubview(backButton)
        wrapper.addSubview(textFieldWrapper)
        textFieldWrapper.addSubview(textField)
        textFieldWrapper.addSubview(clearButton)

        clearButton.alpha = 0.0

        backButton.onTap = {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            heightAnchor.constraint(equalToConstant: max(topPadding + 64, 64)),

            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapper.topAnchor.constraint(equalTo: topAnchor),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),

            blurView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: -1),
            blurView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: 1),
            blurView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: -1),
            blurView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),

            backButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            backButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),

            textFieldWrapper.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            textFieldWrapper.bottomAnchor.constraint(equalTo: backButton.bottomAnchor),
            textFieldWrapper.topAnchor.constraint(equalTo: backButton.topAnchor),
            textFieldWrapper.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),

            textField.leadingAnchor.constraint(equalTo: textFieldWrapper.leadingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: clearButton.trailingAnchor, constant: -6),
            textField.topAnchor.constraint(equalTo: textFieldWrapper.topAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldWrapper.bottomAnchor),

            clearButton.trailingAnchor.constraint(equalTo: textFieldWrapper.trailingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: textFieldWrapper.centerYAnchor)
        ])
    }
}
