//
//  TabBar.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

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

 protocol CustomTabbarDelegate: AnyObject {
    func didSelectTab(_ tab: Int)
}

 class TabBar: UIView {

     let wrapper: UIView = {
        let view = UIView()
        view.backgroundColor = .container
        view.layer.borderColor = UIColor.border.cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     let tabStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

     let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .accent
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     let circleView = UIView()

    // swiftlint:disable implicitly_unwrapped_optional
     var indicatorOffset: NSLayoutConstraint!
     var circleOffset: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

     weak var delegate: CustomTabbarDelegate?

     init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override  init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

     required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

     var selectedTab = 0

     let tempTabs = ["Home", "Discover", "Repo"]
     let tempTabsIcons = ["house", "safari", "shippingbox"]

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let index = sender.index else { return }
        
        switchToTab(index)
    }
    
    private func switchToTab(_ index: Int) {
        let oldTabView = tabStack.subviews[selectedTab] as! TabBarItem
        let selectedTabView = tabStack.subviews[index] as! TabBarItem

        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.delegate?.didSelectTab(index)

            self.indicatorOffset.constant = selectedTabView.frame.minX
            self.circleOffset.constant = selectedTabView.frame.minX

            oldTabView.alpha = 0.7
            selectedTabView.alpha = 1.0

            oldTabView.icon.image = UIImage(systemName: self.tempTabsIcons[self.selectedTab])
            selectedTabView.icon.image = UIImage(systemName: self.tempTabsIcons[index] + ".fill")

            self.layoutIfNeeded()

            self.selectedTab = index
        }
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        circleView.backgroundColor = .accent
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
            let view = TabBarItem(
                label: tempTabs[i],
                icon: UIImage(systemName: tempTabsIcons[i] + (selectedTab == i ? ".fill" : ""))
            )

            view.alpha = selectedTab == i ? 1.0 : 0.7

            tabStack.addArrangedSubview(view)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture.index = i
            view.addGestureRecognizer(tapGesture)
        }

        wrapper.addSubview(tabStack)

        addSubview(wrapper)
        addSubview(indicatorView)
    }

    private func setupConstraints() {
        let selectedTabView = tabStack.subviews[0]

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

    override  func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        wrapper.backgroundColor = .container

        indicatorView.backgroundColor = .accent

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
