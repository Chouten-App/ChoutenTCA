//
//  TopBar.swift
//  Chouten
//
//  Created by Resty on 23.01.25.
//

import UIKit


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
