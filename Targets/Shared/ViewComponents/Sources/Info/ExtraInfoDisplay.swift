//
//  ExtraInfoDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 08.02.24.
//

import Architecture
import SharedModels
import UIKit

public class ExtraInfoDisplay: UIView {

    public var infoData: InfoData

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let tagsDisplay: TagDisplay

    let descriptionLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = ThemeManager.shared.getColor(for: .fg)
        label.font          = UIFont.systemFont(ofSize: 14)
        label.alpha         = 0.7
        label.numberOfLines = 9
        return label
    }()

    // MARK: Lifecycle

    public init(infoData: InfoData) {
        self.infoData = infoData
        self.tagsDisplay = TagDisplay(infoData: infoData)
        super.init(frame: .zero)
        configure()
        setupConstraints()
        updateData()
    }

    // MARK: View Lifecycle

    override public init(frame: CGRect) {
        self.infoData = .sample
        self.tagsDisplay = TagDisplay(infoData: infoData)
        super.init(frame: frame)
        configure()
        setupConstraints()
        updateData()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func configure() {
        if !infoData.tags.isEmpty {
            stack.addArrangedSubview(tagsDisplay)
        }
        stack.addArrangedSubview(descriptionLabel)

        addSubview(stack)
    }

    public func updateData() {
        tagsDisplay.infoData = infoData
        tagsDisplay.updateData()

        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if !infoData.tags.isEmpty {
            stack.addArrangedSubview(tagsDisplay)
        }
        stack.addArrangedSubview(descriptionLabel)

        let paragraphStyle = NSMutableParagraphStyle()
        let attstr = NSMutableAttributedString(string: infoData.sanitizedDescription)
        paragraphStyle.hyphenationFactor = 1.0
        attstr.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(0..<attstr.length))
        descriptionLabel.attributedText = attstr
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        if !infoData.tags.isEmpty {
            NSLayoutConstraint.activate([
                tagsDisplay.heightAnchor.constraint(equalToConstant: 24)
            ])
        }
    }
}
