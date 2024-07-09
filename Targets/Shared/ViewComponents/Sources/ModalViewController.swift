//
//  ModalViewController.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 05.03.24.
//

import Architecture
import UIKit

public class ModalViewController: UIViewController {

    public let minimumHeight: CGFloat = 56
    public var isExpanded = false

    // swiftlint:disable implicitly_unwrapped_optional
    public var heightAnchor: NSLayoutConstraint!
    // swiftlint:enable implicitly_unwrapped_optional

    public var snapPoints: [CGFloat] = [70, 320, 700] // Custom snap points

    public let wrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5

        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let titleWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let selectedModuleTitle: UILabel = {
        let label = UILabel()
        label.text = "Module Name"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let dragBar: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .fg)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let moduleSelectorView = ModuleSelectorView()

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        configure()

        setupConstraints()

        // Add gesture recognizer for tapping to expand/collapse
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
                wrapper.addGestureRecognizer(panGesture)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        wrapper.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        wrapper.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        titleWrapper.backgroundColor = ThemeManager.shared.getColor(for: .container)
        selectedModuleTitle.textColor = ThemeManager.shared.getColor(for: .fg)
        dragBar.backgroundColor = ThemeManager.shared.getColor(for: .fg)
    }

    // Other methods...

    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard sender.view != nil else { return }

        let translation = sender.translation(in: self.view)
        let newYPosition = max(minimumHeight, heightAnchor.constant - translation.y)

        if sender.state == .ended {
            if newYPosition >= 550 {
                animateToNearestSnapPoint(UIScreen.main.bounds.height - 90 - 120, sender)
            } else if newYPosition >= 200 && newYPosition < 550 {
                animateToNearestSnapPoint(340, sender)
            } else {
                animateToNearestSnapPoint(minimumHeight, sender)
            }
        } else {
            heightAnchor.constant = newYPosition
            sender.setTranslation(.zero, in: self.view)
        }
    }

    private func animateToNearestSnapPoint(_ snapPoint: CGFloat, _ sender: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.heightAnchor.constant = snapPoint
            self.view.layoutIfNeeded()
        }, completion: { _ in
            sender.setTranslation(.zero, in: self.view)
        })
    }

    private func configure() {
        view.addSubview(wrapper)
        wrapper.addSubview(titleWrapper)
        titleWrapper.addSubview(selectedModuleTitle)
        titleWrapper.addSubview(dragBar)

        addChild(moduleSelectorView)
        wrapper.addSubview(moduleSelectorView.view)

        moduleSelectorView.view.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wrapper.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            wrapper.topAnchor.constraint(equalTo: view.topAnchor),

            titleWrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleWrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleWrapper.topAnchor.constraint(equalTo: wrapper.topAnchor),
            titleWrapper.heightAnchor.constraint(equalToConstant: 46),

            selectedModuleTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            selectedModuleTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            selectedModuleTitle.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),

            dragBar.widthAnchor.constraint(equalToConstant: 24),
            dragBar.heightAnchor.constraint(equalToConstant: 4),
            dragBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragBar.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 6),

            moduleSelectorView.view.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            moduleSelectorView.view.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            moduleSelectorView.view.topAnchor.constraint(equalTo: titleWrapper.bottomAnchor),
            moduleSelectorView.view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])

        heightAnchor = view.heightAnchor.constraint(equalToConstant: minimumHeight)
        heightAnchor.isActive = true
    }

    deinit {
        moduleSelectorView.removeFromParent()
    }
}
