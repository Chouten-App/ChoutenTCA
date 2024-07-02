//
//  LoadingExtraInfoDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 19.02.24.
//

import Architecture
import UIKit

public class LoadingExtraInfoDisplay: UIView {

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let tagsDisplay: LoadingTagDisplay

    let descriptionLabel: UILabel = {
        let label           = UILabel()
        label.text          = "Description"
        label.textColor     = ThemeManager.shared.getColor(for: .fg)
        label.alpha         = 0.7
        label.numberOfLines = 9
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: Lifecycle

    public init() {
        self.tagsDisplay = LoadingTagDisplay()
        super.init(frame: .zero)
        configure()
        updateData()
        setupConstraints()
    }

    // MARK: View Lifecycle

    override public init(frame: CGRect) {
        self.tagsDisplay = LoadingTagDisplay()
        super.init(frame: frame)
        configure()
        updateData()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func configure() {
        stack.addArrangedSubview(tagsDisplay)

        for _ in 0..<8 {
            let temp = UIView()
            temp.backgroundColor = ThemeManager.shared.getColor(for: .container)
            temp.alpha = 0.5
            temp.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            temp.layer.borderWidth = 0.5
            temp.layer.cornerRadius = 4
            temp.translatesAutoresizingMaskIntoConstraints = false

            stack.addArrangedSubview(temp)

            NSLayoutConstraint.activate([
                temp.heightAnchor.constraint(equalToConstant: 16)
            ])
        }

        let temp = UIView()
        temp.backgroundColor = ThemeManager.shared.getColor(for: .container)
        temp.alpha = 0.5
        temp.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        temp.layer.borderWidth = 0.5
        temp.layer.cornerRadius = 4
        temp.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        addSubview(temp)

        NSLayoutConstraint.activate([
            temp.heightAnchor.constraint(equalToConstant: 16),
            temp.widthAnchor.constraint(equalToConstant: 240),
            temp.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            temp.leadingAnchor.constraint(equalTo: stack.leadingAnchor)
        ])
    }

    private func updateData() {
    }

    // MARK: Layout

    private func setupConstraints() {
        let height = 16.0 * 9.0 + (8.0 * 8.0)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height + 24 + 8),

            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),

            tagsDisplay.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
