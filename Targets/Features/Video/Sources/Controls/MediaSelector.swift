//
//  MediaSelector.swift
//  Video
//
//  Created by Inumaki on 08.07.24.
//

import Architecture
import ViewComponents
import UIKit

class MediaSelector: UIView {

    let blurView: UIVisualEffectView = {
        let effect              = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view                = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let seasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Season 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let mediaCountLabel: UILabel = {
        let label = UILabel()
        label.text = "12 Episodes"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 14)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let seasonButton = CircleButton(icon: "chevron.down")

    let closeButton = CircleButton(icon: "xmark")

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(blurView)

        addSubview(closeButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 30)
        ])
    }
}
