//
//  InfoTopBar.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import UIKit
import GoogleCast

class InfoTopBar: UIView {

    let title: String

    let wrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let blurView = VariableBlurUIView()

    let backButton = CircleButton(icon: "chevron.left")
    var bookmarkButton = CircleButton(icon: "bookmark")
    
    let castButton = GCKUICastButton()

    let titleLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = ThemeManager.shared.getColor(for: .fg)
        label.font          = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        label.lineBreakStrategy = []
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let titleHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let marqueeWrapper = UIView()

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override init(frame: CGRect) {
        self.title = "Title"
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        titleHorizontalStack.addArrangedSubview(titleLabel)
        // titleHorizontalStack.addArrangedSubview(bookmarkButton)
        
        marqueeWrapper.clipsToBounds = true
        marqueeWrapper.translatesAutoresizingMaskIntoConstraints = false
        marqueeWrapper.addSubview(titleHorizontalStack)

        translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(blurView)

        horizontalStack.addArrangedSubview(backButton)

        wrapper.addSubview(horizontalStack)
        wrapper.addSubview(marqueeWrapper)
        addSubview(wrapper)

        // update title
        titleLabel.text = title

        titleLabel.alpha = 0.0
        blurView.alpha = 0.0
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        castButton.translatesAutoresizingMaskIntoConstraints = false
        // titleHorizontalStack.addArrangedSubview(castButton)

        backButton.onTap = {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    // MARK: Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapper.topAnchor.constraint(equalTo: topAnchor),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),

            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            horizontalStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            horizontalStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12 - 30),

            marqueeWrapper.topAnchor.constraint(equalTo: backButton.topAnchor),
            marqueeWrapper.bottomAnchor.constraint(equalTo: backButton.bottomAnchor),
            marqueeWrapper.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            marqueeWrapper.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -20),

            titleHorizontalStack.centerYAnchor.constraint(equalTo: marqueeWrapper.centerYAnchor),
            titleHorizontalStack.leadingAnchor.constraint(equalTo: marqueeWrapper.leadingAnchor),
            titleHorizontalStack.trailingAnchor.constraint(equalTo: marqueeWrapper.trailingAnchor)
        ])
    }
}
