//
//  SeasonSelectorView.swift
//  ViewComponents
//
//  Created by Inumaki on 27.06.24.
//

import Architecture
import SharedModels
import UIKit

public class SeasonSelectorView: UIView {

    let seasonData: [SeasonData]

    let blurView: UIVisualEffectView = {
        let effect              = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view                = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let scrollView: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.alwaysBounceVertical = true
        scrollview.showsVerticalScrollIndicator = false
        scrollview.translatesAutoresizingMaskIntoConstraints = false
        return scrollview
    }()

    let seasonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let closeButton = SeasonSelectorCloseButton()

    var selectedSeason: Int = 0

    public init(_ data: [SeasonData]) {
        self.seasonData = data
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        scrollView.addSubview(seasonStack)
        addSubview(scrollView)

        for index in 0..<seasonData.count {
            let data = seasonData[index]

            if data.selected == true {
                selectedSeason = index
            }

            let label = UILabel()
            label.text = data.name
            label.textColor = ThemeManager.shared.getColor(for: .fg)
            label.font = .systemFont(ofSize: index == selectedSeason ? 20 : 16, weight: index == selectedSeason ? .bold : .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false

            seasonStack.addArrangedSubview(label)
        }

        addSubview(closeButton)
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0

        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            seasonStack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            seasonStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),

            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomPadding + 40.0)
        ])
    }
}
