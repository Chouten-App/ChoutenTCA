//
//  TagDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 08.02.24.
//

import Architecture
import SharedModels
import UIKit

class TagDisplay: UIView {

    var infoData: InfoData

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

    init(infoData: InfoData) {
        self.infoData = infoData
        super.init(frame: .zero)
        configure()
        setupConstraints()
        updateData()
    }

    // MARK: View Lifecycle

    override init(frame: CGRect) {
        self.infoData = .sample
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

    func updateData() {
        contentView.arrangedSubviews
            .forEach({ $0.removeFromSuperview() })

        for index in 0..<infoData.tags.count {
            let tag = infoData.tags[index]

            let tagView = UIView()
            tagView.translatesAutoresizingMaskIntoConstraints = false

            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            let effectView = UIVisualEffectView(effect: blurEffect)
            effectView.translatesAutoresizingMaskIntoConstraints = false

            tagView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            tagView.layer.borderWidth = 0.5
            tagView.layer.cornerRadius = 6
            tagView.clipsToBounds = true

            let label = UILabel()
            label.text = tag
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = ThemeManager.shared.getColor(for: .fg)
            label.translatesAutoresizingMaskIntoConstraints = false

            tagView.addSubview(effectView)
            tagView.addSubview(label)
            tagView.sendSubviewToBack(effectView)

            contentView.addArrangedSubview(tagView)

            NSLayoutConstraint.activate([
                tagView.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 24),

                effectView.leadingAnchor.constraint(equalTo: tagView.leadingAnchor),
                effectView.trailingAnchor.constraint(equalTo: tagView.trailingAnchor),
                effectView.topAnchor.constraint(equalTo: tagView.topAnchor),
                effectView.bottomAnchor.constraint(equalTo: tagView.bottomAnchor),

                label.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: tagView.centerYAnchor)
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
