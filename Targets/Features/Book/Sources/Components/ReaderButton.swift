//
//  ReaderButton.swift
//  Book
//
//  Created by Inumaki on 02.08.24.
//

import Architecture
import UIKit

class ReaderButton: UIView {
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var onTap: (() -> Void)?

    init(_ name: String) {
        super.init(frame: .zero)

        imageView.image = UIImage(named: name)

        configure()
        setupConstraints()
    }

    init(systemName: String) {
        super.init(frame: .zero)

        imageView.image = UIImage(systemName: systemName)?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(
                .init(
                    font: .systemFont(ofSize: 18)
                )
            )
        imageView.tintColor = ThemeManager.shared.getColor(for: .fg)

        configure()
        setupConstraints()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 8

        addSubview(imageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 42),
            heightAnchor.constraint(equalToConstant: 42),

            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func disabled(_ value: Bool) {}

    @objc func handleTap() {
        onTap?()
    }
}
