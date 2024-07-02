//
//  AppearanceVC.swift
//  Settings
//
//  Created by Inumaki on 26.06.24.
//

import Architecture
import UIKit

protocol AccentCircleDelegate: AnyObject {
    func updateAccent()
}

class AccentCircle: UIView {
    let color: UIColor
    let index: Int

    weak var delegate: AccentCircleDelegate?

    let overlay: UIView = {
        let overlay = UIView()
        overlay.layer.cornerRadius = 15
        overlay.layer.borderColor = ThemeManager.shared.getColor(for: .container).cgColor
        overlay.layer.borderWidth = 3
        overlay.translatesAutoresizingMaskIntoConstraints = false
        return overlay
    }()

    init(color: UIColor, index: Int) {
        self.color = color
        self.index = index
        super.init(frame: .zero)
        setupView()
    }

    override init(frame: CGRect) {
        self.color = .systemIndigo
        self.index = 0
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.color = .systemIndigo
        self.index = 0
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = color
        layer.cornerRadius = 20
        translatesAutoresizingMaskIntoConstraints = false

        overlay.backgroundColor = color
        overlay.alpha = 0.0

        addSubview(overlay)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 40),
            heightAnchor.constraint(equalToConstant: 40),

            overlay.widthAnchor.constraint(equalToConstant: 30),
            overlay.heightAnchor.constraint(equalToConstant: 30),
            overlay.centerXAnchor.constraint(equalTo: centerXAnchor),
            overlay.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setAccent))
        addGestureRecognizer(tapGesture)
    }

    @objc func setAccent() {
        ThemeManager.shared.accent = index
        UIView.animate(withDuration: 0.2) {
            self.delegate?.updateAccent()
        }
    }
}

class AppearancePreview: UIView {
    let light: Bool

    // MARK: - Properties
    let carouselCard: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.1
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let sectionTitle: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.1
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let sectionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initializer
    init(light: Bool = false) {
        self.light = light
        super.init(frame: .zero)
        setupView()
    }

    override init(frame: CGRect) {
        self.light = false
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.light = false
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.shared.getColor(for: .bg, light: light)
        layer.borderColor = ThemeManager.shared.getColor(for: .border, light: light).cgColor
        layer.borderWidth = 0.1
        layer.cornerRadius = 8

        carouselCard.backgroundColor = ThemeManager.shared.getColor(for: .container, light: light)
        carouselCard.layer.borderColor = ThemeManager.shared.getColor(for: .border, light: light).cgColor

        sectionTitle.backgroundColor = ThemeManager.shared.getColor(for: .overlay, light: light)
        sectionTitle.layer.borderColor = ThemeManager.shared.getColor(for: .border, light: light).cgColor

        addSubview(carouselCard)
        addSubview(sectionTitle)
        addSubview(sectionStack)

        for _ in 0..<4 {
            let card = UIView()
            card.backgroundColor = ThemeManager.shared.getColor(for: .container, light: light)
            card.layer.borderColor = ThemeManager.shared.getColor(for: .border, light: light).cgColor
            card.layer.borderWidth = 0.1
            card.layer.cornerRadius = 4
            card.translatesAutoresizingMaskIntoConstraints = false

            let cardOverlay = UIView()
            cardOverlay.backgroundColor = ThemeManager.shared.getColor(for: .overlay, light: light)
            cardOverlay.layer.borderColor = ThemeManager.shared.getColor(for: .border, light: light).cgColor
            cardOverlay.layer.borderWidth = 0.1
            cardOverlay.layer.cornerRadius = 1
            cardOverlay.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(cardOverlay)

            sectionStack.addArrangedSubview(card)

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 14),
                card.heightAnchor.constraint(equalToConstant: 20),

                cardOverlay.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -1),
                cardOverlay.topAnchor.constraint(equalTo: card.topAnchor, constant: 1),
                cardOverlay.widthAnchor.constraint(equalToConstant: 5),
                cardOverlay.heightAnchor.constraint(equalToConstant: 2)
            ])
        }

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 64),
            heightAnchor.constraint(equalToConstant: 120),

            carouselCard.centerXAnchor.constraint(equalTo: centerXAnchor),
            carouselCard.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            carouselCard.widthAnchor.constraint(equalToConstant: 44),
            carouselCard.heightAnchor.constraint(equalToConstant: 60),

            sectionTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            sectionTitle.topAnchor.constraint(equalTo: carouselCard.bottomAnchor, constant: 8),
            sectionTitle.widthAnchor.constraint(equalToConstant: 16),
            sectionTitle.heightAnchor.constraint(equalToConstant: 3),

            sectionStack.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 3),
            sectionStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            sectionStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            sectionStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

class Group: UIView, AccentCircleDelegate {

    // MARK: - Properties
    let groupTitle: UILabel = {
        let label = UILabel()
        label.text = "Appearance"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 15, weight: .medium)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let group: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.cornerRadius = 20
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let accentColors: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let preview = AppearancePreview(light: false)
    let previewLight = AppearancePreview(light: true)
    let previewAuto = AppearancePreview(light: false)
    let previewAutoOverlay = AppearancePreview(light: true)

    let previewSelected: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .accent).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 9
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let previewLightSelected: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent).withAlphaComponent(0.0)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .overlay).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 9
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let previewAutoSelected: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent).withAlphaComponent(0.0)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .overlay).cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 9
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let accentColorTitle: UILabel = {
        let label = UILabel()
        label.text = "Accent Color"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let accentColorValue: UILabel = {
        let label = UILabel()
        label.text = "Indigo"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 12)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    private func setupView() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        if let window {
            setSelectedCircles(window.overrideUserInterfaceStyle)
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        addSubview(groupTitle)
        addSubview(group)
        clipsToBounds = true

        group.addSubview(preview)
        group.addSubview(previewLight)
        group.addSubview(previewAuto)

        let overlayWrapper = UIView()
        overlayWrapper.translatesAutoresizingMaskIntoConstraints = false
        overlayWrapper.addSubview(previewAutoOverlay)
        group.addSubview(overlayWrapper)
        overlayWrapper.clipsToBounds = true

        group.addSubview(previewSelected)
        group.addSubview(previewLightSelected)
        group.addSubview(previewAutoSelected)

        for index in 0..<ThemeManager.shared.accentColors.count {
            let color = ThemeManager.shared.accentColors[index]
            let circle = AccentCircle(color: color, index: index)

            circle.delegate = self

            if index == ThemeManager.shared.accent {
                circle.overlay.alpha = 1.0
            }

            accentColors.addArrangedSubview(circle)
        }

        group.addSubview(accentColorTitle)
        group.addSubview(accentColorValue)

        group.addSubview(accentColors)

        NSLayoutConstraint.activate([
            groupTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            groupTitle.topAnchor.constraint(equalTo: topAnchor),

            group.leadingAnchor.constraint(equalTo: leadingAnchor),
            group.trailingAnchor.constraint(equalTo: trailingAnchor),
            group.topAnchor.constraint(equalTo: groupTitle.bottomAnchor, constant: 4),
            group.bottomAnchor.constraint(equalTo: bottomAnchor),

            preview.topAnchor.constraint(equalTo: group.topAnchor, constant: 26),
            previewLight.topAnchor.constraint(equalTo: group.topAnchor, constant: 26),
            previewAuto.topAnchor.constraint(equalTo: group.topAnchor, constant: 26),
            overlayWrapper.topAnchor.constraint(equalTo: group.topAnchor, constant: 26),

            preview.leadingAnchor.constraint(equalTo: group.leadingAnchor, constant: 50),
            previewAuto.trailingAnchor.constraint(equalTo: group.trailingAnchor, constant: -50),
            previewLight.centerXAnchor.constraint(equalTo: group.centerXAnchor),

            overlayWrapper.trailingAnchor.constraint(equalTo: previewAuto.trailingAnchor),
            overlayWrapper.widthAnchor.constraint(equalToConstant: 32),
            overlayWrapper.heightAnchor.constraint(equalToConstant: 120),
            previewAutoOverlay.trailingAnchor.constraint(equalTo: overlayWrapper.trailingAnchor),

            previewSelected.centerXAnchor.constraint(equalTo: preview.centerXAnchor),
            previewSelected.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 16),
            previewSelected.widthAnchor.constraint(equalToConstant: 18),
            previewSelected.heightAnchor.constraint(equalToConstant: 18),

            previewLightSelected.centerXAnchor.constraint(equalTo: previewLight.centerXAnchor),
            previewLightSelected.topAnchor.constraint(equalTo: previewLight.bottomAnchor, constant: 16),
            previewLightSelected.widthAnchor.constraint(equalToConstant: 18),
            previewLightSelected.heightAnchor.constraint(equalToConstant: 18),

            previewAutoSelected.centerXAnchor.constraint(equalTo: previewAuto.centerXAnchor),
            previewAutoSelected.topAnchor.constraint(equalTo: previewAuto.bottomAnchor, constant: 16),
            previewAutoSelected.widthAnchor.constraint(equalToConstant: 18),
            previewAutoSelected.heightAnchor.constraint(equalToConstant: 18),

            accentColorTitle.leadingAnchor.constraint(equalTo: group.leadingAnchor, constant: 16),
            accentColorTitle.topAnchor.constraint(equalTo: previewSelected.bottomAnchor, constant: 12),

            accentColorValue.centerYAnchor.constraint(equalTo: accentColorTitle.centerYAnchor),
            accentColorValue.trailingAnchor.constraint(equalTo: group.trailingAnchor, constant: -16),

            accentColors.leadingAnchor.constraint(equalTo: group.leadingAnchor, constant: 16),
            accentColors.trailingAnchor.constraint(equalTo: group.trailingAnchor, constant: -16),
            accentColors.bottomAnchor.constraint(equalTo: group.bottomAnchor, constant: -20),
            accentColors.topAnchor.constraint(equalTo: accentColorTitle.bottomAnchor, constant: 12)
        ])

        // setup taps for appearanceChange

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setDarkAppearance))
        preview.isUserInteractionEnabled = true
        preview.addGestureRecognizer(tapGesture)

        let tapGestureLight = UITapGestureRecognizer(target: self, action: #selector(setLightAppearance))
        previewLight.isUserInteractionEnabled = true
        previewLight.addGestureRecognizer(tapGestureLight)

        let tapGestureAuto = UITapGestureRecognizer(target: self, action: #selector(setAutoAppearance))
        previewAuto.isUserInteractionEnabled = true
        previewAuto.addGestureRecognizer(tapGestureAuto)

        overlayWrapper.isUserInteractionEnabled = false
    }

    func updateAppearance() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        UIView.animate(withDuration: 0.2) {
            self.group.backgroundColor = ThemeManager.shared.getColor(for: .container)
            self.group.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            self.groupTitle.textColor = ThemeManager.shared.getColor(for: .fg)
            self.accentColorTitle.textColor = ThemeManager.shared.getColor(for: .fg)
            self.accentColorValue.textColor = ThemeManager.shared.getColor(for: .fg)
        }

        updateAccent()
    }

    func setSelectedCircles(_ style: UIUserInterfaceStyle) {
        previewSelected.backgroundColor = ThemeManager.shared.getColor(for: .accent).withAlphaComponent(style == .dark ? 1.0 : 0.0)
        previewLightSelected.backgroundColor = ThemeManager.shared.getColor(for: .accent).withAlphaComponent(style == .light ? 1.0 : 0.0)
        previewAutoSelected.backgroundColor = ThemeManager.shared.getColor(for: .accent).withAlphaComponent(style == .unspecified ? 1.0 : 0.0)

        previewSelected.layer.borderColor = ThemeManager.shared.getColor(for: style == .dark ? .accent : .border).cgColor
        previewLightSelected.layer.borderColor = ThemeManager.shared.getColor(for: style == .light ? .accent : .border).cgColor
        previewAutoSelected.layer.borderColor = ThemeManager.shared.getColor(for: style == .unspecified ? .accent : .border).cgColor
    }

    func updateAccent() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        for index in 0..<accentColors.arrangedSubviews.count {
            if let circle = accentColors.arrangedSubviews[index] as? AccentCircle {
                circle.overlay.alpha = index == ThemeManager.shared.accent ? 1.0 : 0.0
                circle.overlay.layer.borderColor = ThemeManager.shared.getColor(for: .container).cgColor
            }
        }

        accentColorValue.text = ThemeManager.shared.accentColorNames[ThemeManager.shared.accent]

        if let window {
            window.backgroundColor = ThemeManager.shared.getColor(for: .bg)
            window.rootViewController?.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
            setSelectedCircles(window.overrideUserInterfaceStyle)
            triggerTraitCollectionDidChange(for: window.rootViewController)
        }
    }

    @objc func setDarkAppearance() {
        UserDefaults.standard.setValue(0, forKey: "currentStyle")

        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        // Start with auto mode (system default)
        window?.overrideUserInterfaceStyle = .dark

        setSelectedCircles(.dark)

        updateAppearance()
        if let window {
            triggerTraitCollectionDidChange(for: window.rootViewController)
            window.backgroundColor = ThemeManager.shared.getColor(for: .bg)
            window.rootViewController?.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        }
    }

    @objc func setLightAppearance() {
        UserDefaults.standard.setValue(1, forKey: "currentStyle")
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        // Start with auto mode (system default)
        window?.overrideUserInterfaceStyle = .light

        setSelectedCircles(.light)

        updateAppearance()
        if let window {
            triggerTraitCollectionDidChange(for: window.rootViewController)
            window.backgroundColor = ThemeManager.shared.getColor(for: .bg)
            window.rootViewController?.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        }
    }

    @objc func setAutoAppearance() {
        UserDefaults.standard.setValue(2, forKey: "currentStyle")
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        // Start with auto mode (system default)
        window?.overrideUserInterfaceStyle = .unspecified

        setSelectedCircles(.unspecified)

        updateAppearance()
        if let window {
            triggerTraitCollectionDidChange(for: window.rootViewController)
            window.backgroundColor = ThemeManager.shared.getColor(for: .bg)
            window.rootViewController?.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        }
    }

    private func triggerTraitCollectionDidChange(for viewController: UIViewController?) {
        guard let viewController = viewController else { return }

        // Notify the view controller of the trait collection change
        viewController.traitCollectionDidChange(nil)

        // Recursively notify child view controllers
        for childVC in viewController.children {
            triggerTraitCollectionDidChange(for: childVC)
        }

        // If the view controller is a container, notify the presented view controller
        if let presentedVC = viewController.presentedViewController {
            triggerTraitCollectionDidChange(for: presentedVC)
        }
    }
}

class AppearanceVC: UIViewController {

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let group = Group()
    let group2 = Group()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        configure()
        setupConstraints()
    }

    private func configure() {
        stack.addArrangedSubview(group)
        stack.addArrangedSubview(group2)

        scrollView.addSubview(stack)

        view.addSubview(scrollView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // group.heightAnchor.constraint(equalToConstant: 200),
            group.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            group.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            group2.heightAnchor.constraint(equalToConstant: 0),
            group2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            group2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 60),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateAppearance()
    }

    func updateAppearance() {
        self.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
    }
}
