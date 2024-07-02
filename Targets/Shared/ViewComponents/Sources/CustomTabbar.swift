//
//  CustomTabbar.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 23.02.24.
//

import Architecture
import UIKit

private var indexKey: UInt8 = 0

extension UITapGestureRecognizer {
    var index: Int? {
        get {
            objc_getAssociatedObject(self, &indexKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &indexKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

public protocol CustomTabbarDelegate: AnyObject {
    func didSelectTab(_ tab: Int)
}

public class CustomTabbar: UIView {

    public let wrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let tabStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let circleView = UIView()

    // swiftlint:disable implicitly_unwrapped_optional
    public var indicatorOffset: NSLayoutConstraint!
    public var circleOffset: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    public weak var delegate: CustomTabbarDelegate?

    public init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var selectedTab = 0

    public let tempTabs = ["Home", "Discover", "Repo"]
    public let tempTabsIcons = ["house", "safari", "shippingbox"]

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.index else { return }
        // Now you have access to the tapped index
        print("Tapped index:", index)
        let oldTabView = tabStack.subviews[selectedTab]
        let selectedTabView = tabStack.subviews[index]

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) { // Adjust duration as needed
            self.delegate?.didSelectTab(index)

            print(selectedTabView.frame.minX)

            self.indicatorOffset.constant = selectedTabView.frame.minX
            self.circleOffset.constant = selectedTabView.frame.minX

            oldTabView.alpha = 0.7
            selectedTabView.alpha = 1.0

            let oldImageView: UIImageView? = oldTabView.subviews.first { uiview in
                uiview is UIImageView
            } as? UIImageView
            oldImageView?.image = UIImage(systemName: self.tempTabsIcons[self.selectedTab])

            let imageView: UIImageView? = selectedTabView.subviews.first { uiview in
                uiview is UIImageView
            } as? UIImageView
            imageView?.image = UIImage(systemName: self.tempTabsIcons[index] + ".fill")

            self.layoutIfNeeded() // Update layout immediately within the animation block

            self.selectedTab = index
        }
    }

    private func configure() {
        circleView.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        circleView.layer.cornerRadius = 60
        circleView.alpha = 0.3
        circleView.translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(circleView)

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = wrapper.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wrapper.addSubview(blurEffectView)

        for i in 0..<tempTabs.count {
            let view = UIView()
            view.isUserInteractionEnabled = true

            let icon = UIImageView(image: UIImage(systemName: tempTabsIcons[i] + (selectedTab == i ? ".fill" : "")))
            icon.tintColor = ThemeManager.shared.getColor(for: .fg)
            icon.contentMode = .scaleAspectFill
            icon.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(icon)

            let label = UILabel()
            label.text = tempTabs[i]
            label.textColor = ThemeManager.shared.getColor(for: .fg)
            label.font = UIFont.systemFont(ofSize: 12)
            label.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(label)

            view.sendSubviewToBack(circleView)

            view.alpha = selectedTab == i ? 1.0 : 0.7

            tabStack.addArrangedSubview(view)

            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalToConstant: 44),
                view.heightAnchor.constraint(equalToConstant: 44),

                icon.widthAnchor.constraint(equalToConstant: 24),
                icon.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
                icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 8),
                label.centerXAnchor.constraint(equalTo: icon.centerXAnchor)
            ])

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture.index = i
            view.addGestureRecognizer(tapGesture)
        }

        wrapper.addSubview(tabStack)

        addSubview(wrapper)
        addSubview(indicatorView)
    }

    private func setupConstraints() {
        let selectedTabView = tabStack.subviews[selectedTab]

        NSLayoutConstraint.activate([
            wrapper.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width + 2),
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1),
            wrapper.topAnchor.constraint(equalTo: topAnchor),

            tabStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 60),
            tabStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -60),
            tabStack.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),
            tabStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),

            indicatorView.widthAnchor.constraint(equalToConstant: 24),
            indicatorView.heightAnchor.constraint(equalToConstant: 4),
            indicatorView.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: -2),

            circleView.widthAnchor.constraint(equalToConstant: 120),
            circleView.heightAnchor.constraint(equalToConstant: 120),
            circleView.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor, constant: -12)
        ])

        indicatorOffset = indicatorView.centerXAnchor.constraint(equalTo: selectedTabView.centerXAnchor)
        indicatorOffset.isActive = true

        circleOffset = circleView.centerXAnchor.constraint(equalTo: selectedTabView.centerXAnchor)
        circleOffset.isActive = true
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        wrapper.backgroundColor = ThemeManager.shared.getColor(for: .container)

        indicatorView.backgroundColor = ThemeManager.shared.getColor(for: .accent)

        for index in 0..<tabStack.arrangedSubviews.count {
            let tab = tabStack.arrangedSubviews[index]

            for subview in tab.subviews {
                if let label = subview as? UILabel {
                    label.textColor = ThemeManager.shared.getColor(for: .fg)
                                            .withAlphaComponent(index == selectedTab ? 1.0 : 0.7)
                } else if let icon = subview as? UIImageView {
                    icon.tintColor = ThemeManager.shared.getColor(for: .fg)
                                            .withAlphaComponent(index == selectedTab ? 1.0 : 0.7)
                }
            }
        }
    }
}
