//
//  AppViewTopBar.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import UIKit
import Core
import ComposableArchitecture

class AppViewTopBar: UIView {
    
    @Dependency(\.repoClient) var repoClient
    
    let blurView: UIView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let wrapper: UIView = {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        return wrapper
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Discover"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let settingsImageWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let settingsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pfp")
        imageView.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let settingsImageWrapper2: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let settingsImage2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon")
        imageView.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let buttonStack: UIStackView = {
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.alignment = .center
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 20
        return buttonStack
    }()
    
    /* OLD
    let interactionWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    */
    
    weak var delegate: AppViewTopBarDelegate?
    
    init() {
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(blurView)
        wrapper.addSubview(label)
        
        settingsImageWrapper.addSubview(settingsImage)
        settingsImageWrapper2.addSubview(settingsImage2)
        
        buttonStack.addArrangedSubview(settingsImageWrapper)
        buttonStack.addArrangedSubview(settingsImageWrapper2)
        
        wrapper.addSubview(buttonStack)
        
        addSubview(wrapper)
        
        /*OLD
        addSubview(interactionWrapper)
                
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSettingsPopover))
        interactionWrapper.isUserInteractionEnabled = true
        interactionWrapper.addGestureRecognizer(tapGesture)
        */
        let tapGestureSettingsIcon = UITapGestureRecognizer(target: self, action: #selector(showSettingsPopover))
        settingsImageWrapper.isUserInteractionEnabled = true
        settingsImageWrapper.addGestureRecognizer(tapGestureSettingsIcon)
        
        let tapGestureModuleIcon = UITapGestureRecognizer(target: self, action: #selector(showModulesPopover))
        settingsImageWrapper2.isUserInteractionEnabled = true
        settingsImageWrapper2.addGestureRecognizer(tapGestureModuleIcon)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wrapper.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width + 2),
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            wrapper.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            blurView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            
            label.centerYAnchor.constraint(equalTo: settingsImageWrapper.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            
            buttonStack.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -15),
            
            settingsImageWrapper.widthAnchor.constraint(equalToConstant: 32),
            settingsImageWrapper.heightAnchor.constraint(equalToConstant: 32),
            
            settingsImageWrapper2.widthAnchor.constraint(equalToConstant: 32),
            settingsImageWrapper2.heightAnchor.constraint(equalToConstant: 32),
            
            settingsImage.centerXAnchor.constraint(equalTo: settingsImageWrapper.centerXAnchor),
            settingsImage.centerYAnchor.constraint(equalTo: settingsImageWrapper.centerYAnchor),
            
            settingsImage2.centerXAnchor.constraint(equalTo: settingsImageWrapper2.centerXAnchor),
            settingsImage2.centerYAnchor.constraint(equalTo: settingsImageWrapper2.centerYAnchor),
            settingsImage2.widthAnchor.constraint(equalTo: settingsImageWrapper2.widthAnchor),
            settingsImage2.heightAnchor.constraint(equalTo: settingsImageWrapper2.heightAnchor),
            
            /*
             -OLD Wrapper for Tab
            interactionWrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            interactionWrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            interactionWrapper.topAnchor.constraint(equalTo: topAnchor),
            interactionWrapper.bottomAnchor.constraint(equalTo: bottomAnchor)
             */
        ])
    }
    
    
    @objc private func showSettingsPopover() {
        delegate?.didTapButton()
    }
    
    @objc private func showModulesPopover() {
        delegate?.didTapModuleIcon()
    }
}
