//
//  LoadingTagDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 19.02.24.
//

import Architecture
import UIKit

class LoadingTagDisplay: UIView {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.axis = .horizontal
        contentView.spacing = 8
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
        updateData()
    }

    // MARK: View Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
        updateData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func configure() {
        scrollView.addSubview(contentView)

        addSubview(scrollView)
    }

    private func updateData() {
        for _ in 0..<6 {
            let tagView = UIView()
            tagView.translatesAutoresizingMaskIntoConstraints = false

            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            let effectView = UIVisualEffectView(effect: blurEffect)
            effectView.translatesAutoresizingMaskIntoConstraints = false

            tagView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            tagView.layer.borderWidth = 0.5
            tagView.layer.cornerRadius = 6
            tagView.clipsToBounds = true

            tagView.addSubview(effectView)
            tagView.sendSubviewToBack(effectView)

            contentView.addArrangedSubview(tagView)

            NSLayoutConstraint.activate([
                tagView.widthAnchor.constraint(equalToConstant: 60),

                effectView.leadingAnchor.constraint(equalTo: tagView.leadingAnchor),
                effectView.trailingAnchor.constraint(equalTo: tagView.trailingAnchor),
                effectView.topAnchor.constraint(equalTo: tagView.topAnchor),
                effectView.bottomAnchor.constraint(equalTo: tagView.bottomAnchor)
            ])
        }
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
}
