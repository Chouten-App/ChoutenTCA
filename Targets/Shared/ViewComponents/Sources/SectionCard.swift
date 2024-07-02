//
//  SectionCard.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Architecture
import Nuke
import SharedModels
import SwiftUI
import UIKit

class SectionCard: UIView {
    let data: DiscoverData

    override init(frame: CGRect) {
        self.data = DiscoverSection.sampleSection.list[3]
        super.init(frame: frame)
        configure()
        setConstraints()
        updateData()
    }

    required init?(coder: NSCoder) {
        self.data = DiscoverSection.sampleSection.list[3]
        super.init(coder: coder)
        configure()
        setConstraints()
        updateData()
    }

    init(data: DiscoverData) {
        self.data = data
        super.init(frame: .zero)
        configure()
        setConstraints()
        updateData()
    }

    let mainView = UIView()
    let imageView = UIImageView()

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let innerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.text = "1 / 12"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let indicator = UIView()

    let indicatorLabel: UILabel = {
        let label = UILabel()
        label.text = "Text"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // swiftlint:disable lower_acl_than_parent
    public weak var delegate: SectionCardDelegate?
    // swiftlint:enable lower_acl_than_parent

    private func configure() {
        mainView.backgroundColor = ThemeManager.shared.getColor(for: .container)
        mainView.layer.cornerRadius = 8
        mainView.clipsToBounds = true
        mainView.layer.borderWidth = 0.5
        mainView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        mainView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(imageView)

        indicator.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        indicator.layer.cornerRadius = 10
        indicator.clipsToBounds = true
        indicator.layer.borderWidth = 0.5
        indicator.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.addSubview(indicatorLabel)
        mainView.addSubview(indicator)

        let imageUrlString = data.poster
        self.imageView.setAsyncImage(url: imageUrlString)

        stack.addArrangedSubview(mainView)

        innerStack.addArrangedSubview(titleLabel)
        innerStack.addArrangedSubview(countLabel)

        stack.addArrangedSubview(innerStack)

        addSubview(stack)

        imageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapRecognizer)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.widthAnchor.constraint(equalToConstant: 110),

            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.widthAnchor.constraint(equalToConstant: 110),
            mainView.heightAnchor.constraint(equalToConstant: 150),

            imageView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: mainView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),

            indicator.widthAnchor.constraint(equalTo: indicatorLabel.widthAnchor, constant: 16), // Add some padding if needed
            indicator.heightAnchor.constraint(equalTo: indicatorLabel.heightAnchor, constant: 8),
            indicator.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8),
            indicator.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8),

            indicatorLabel.trailingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: -8),
            indicatorLabel.topAnchor.constraint(equalTo: indicator.topAnchor, constant: 4)
        ])
    }

    private func updateData() {
        indicatorLabel.text = data.indicator
        titleLabel.text = data.titles.primary
        // swiftlint:disable force_unwrapping
        countLabel.text = "\(data.current != nil ? String(data.current!) : "~")/\(data.total != nil ? String(data.total!) : "~")"
        // swiftlint:enable force_unwrapping
    }

    // swiftlint:disable lower_acl_than_parent
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }
    // swiftlint:enable lower_acl_than_parent

    func updateAppearance() {
        mainView.backgroundColor = ThemeManager.shared.getColor(for: .container)
        mainView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        indicator.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        indicator.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor

        indicatorLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        titleLabel.textColor = ThemeManager.shared.getColor(for: .fg)
        countLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    }

    @objc func handleTap() {
        print("tapped")
        delegate?.didTap(data)
    }
}
