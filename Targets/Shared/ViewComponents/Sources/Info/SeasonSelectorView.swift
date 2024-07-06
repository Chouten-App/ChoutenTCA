//
//  SeasonSelectorView.swift
//  ViewComponents
//
//  Created by Inumaki on 27.06.24.
//

import Architecture
import SharedModels
import UIKit

class SeasonLabelTapGestureRecognizer: UITapGestureRecognizer {
    var seasonIndex: Int?
}

public protocol SeasonSelectorDelegate: AnyObject {
    func didChangeSeason(to: Int)
    func closeSelector()
}

public class SeasonSelectorView: UIView {

    public weak var delegate: SeasonSelectorDelegate?
    
    var seasonData: [SeasonData]

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
        stack.spacing = 20
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let closeButton = SeasonSelectorCloseButton()

    var selectedSeason: Int = -1

    public init(_ data: [SeasonData]) {
        self.seasonData = data
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateData(with data: [SeasonData]) {
        self.seasonData = data

        seasonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if selectedSeason == -1 {
            for (index, data) in seasonData.enumerated() where data.selected == true {
                selectedSeason = index
            }
        }

        for index in 0..<seasonData.count {
            let data = seasonData[index]
            print(data)

            if data.selected == true {
                selectedSeason = index
            }

            let label = UILabel()
            label.text = data.name
            label.textColor = ThemeManager.shared.getColor(for: .fg)
            label.alpha = index == selectedSeason ? 1.0 : 0.7
            label.font = .systemFont(ofSize: index == selectedSeason ? 20 : 16, weight: index == selectedSeason ? .bold : .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false

            label.isUserInteractionEnabled = true
            let tapGesture = SeasonLabelTapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture.seasonIndex = index
            label.addGestureRecognizer(tapGesture)

            seasonStack.addArrangedSubview(label)
        }
    }

    @objc func handleTap(_ sender: SeasonLabelTapGestureRecognizer) {
        selectedSeason = sender.seasonIndex ?? 0
        UIView.animate(withDuration: 0.2) {
            for index in 0..<self.seasonStack.arrangedSubviews.count {
                let view = self.seasonStack.arrangedSubviews[index]
                if let label = view as? UILabel {
                    label.alpha = index == self.selectedSeason ? 1.0 : 0.7
                    label.font = .systemFont(ofSize: index == self.selectedSeason ? 20 : 16, weight: index == self.selectedSeason ? .bold : .semibold)
                }
            }
        }
        delegate?.didChangeSeason(to: selectedSeason)
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        scrollView.addSubview(seasonStack)
        addSubview(scrollView)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)

        closeButton.tapHandler = {
            self.delegate?.closeSelector()
        }
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

            seasonStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            seasonStack.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            seasonStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // seasonStack.heightAnchor.constraint(equalToConstant: 400),

            closeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(bottomPadding + 24.0))
        ])
    }

}
