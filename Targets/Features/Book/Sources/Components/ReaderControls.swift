//
//  ReaderControls.swift
//  Book
//
//  Created by Inumaki on 20.07.24.
//

import Architecture
import UIKit
import ViewComponents

class ReaderControls: UIView {

    let blackOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let backButton = CircleButton(icon: "chevron.left")

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let titleWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let seekbar = SeekBar(progress: 0.0)

    let pagesLabel: UILabel = {
        let label = UILabel()
        label.text = "Page 1 / 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 10)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updatePage(_ page: Int, total: Int) {
        pagesLabel.text = "Page \(page) / \(total)"
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        blackOverlay.isUserInteractionEnabled = true

        titleWrapper.addSubview(titleLabel)

        addSubview(blackOverlay)
        addSubview(backButton)
        addSubview(titleWrapper)
        addSubview(seekbar)
        addSubview(pagesLabel)
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            blackOverlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            blackOverlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            blackOverlay.bottomAnchor.constraint(equalTo: bottomAnchor),
            blackOverlay.topAnchor.constraint(equalTo: topAnchor),

            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: topPadding + 20),

            titleWrapper.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleWrapper.topAnchor.constraint(equalTo: backButton.topAnchor),
            titleWrapper.bottomAnchor.constraint(equalTo: backButton.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: titleWrapper.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleWrapper.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: titleWrapper.centerYAnchor),

            seekbar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            seekbar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            seekbar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            seekbar.heightAnchor.constraint(equalToConstant: 24),

            pagesLabel.topAnchor.constraint(equalTo: seekbar.bottomAnchor, constant: -4),
            pagesLabel.leadingAnchor.constraint(equalTo: seekbar.leadingAnchor),
        ])
    }
}
