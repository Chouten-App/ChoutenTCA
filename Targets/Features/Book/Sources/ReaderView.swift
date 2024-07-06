//
//  DiscoverView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 27.01.24.
//

import Architecture
import Combine
import ComposableArchitecture
import RelayClient
import SharedModels
import UIKit
import ViewComponents

public class ReaderView: UIViewController {

    let backButton = CircleButton(icon: "chevron.left")

    let titleWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 14
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Omniscient Reader's Viewpoint"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let settingsButton = CircleButton(icon: "ellipsis")

    let seekbar = SeekBar(progress: 0.3)

    let pageIndicator: UILabel = {
        let label = UILabel()
        label.text = "Page 9 / 21"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 10)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        titleWrapper.addSubview(titleLabel)
        view.addSubview(backButton)
        view.addSubview(titleWrapper)
        view.addSubview(settingsButton)
        view.addSubview(seekbar)

        seekbar.width = UIScreen.main.bounds.width - 40
        seekbar.layer.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
        seekbar.delegate = self

        view.addSubview(pageIndicator)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),

            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),

            titleWrapper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleWrapper.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            titleWrapper.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: titleWrapper.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: titleWrapper.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: titleWrapper.centerYAnchor),

            seekbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            seekbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            seekbar.bottomAnchor.constraint(equalTo: pageIndicator.topAnchor, constant: 12),
            seekbar.heightAnchor.constraint(equalToConstant: 40),

            pageIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            pageIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        self.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
    }
}

extension ReaderView: SeekBarDelegate {
    public func seekBar(_ seekBar: ViewComponents.SeekBar, didChangeProgress progress: Double) {
        pageIndicator.text = "Page \(Int(progress * 21)) / 21"
    }
}
