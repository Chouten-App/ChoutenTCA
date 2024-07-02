//
//  ErrorMediaListDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 22.02.24.
//

import Architecture
import UIKit

class ErrorMediaListDisplay: UIView {

    let wrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.cornerRadius = 12
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        addSubview(wrapper)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 160),

            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            wrapper.topAnchor.constraint(equalTo: topAnchor),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
