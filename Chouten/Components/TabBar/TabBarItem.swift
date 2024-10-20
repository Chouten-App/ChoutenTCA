//
//  TabBarItem.swift
//  Chouten
//
//  Created by Inumaki on 18/10/2024.
//

import UIKit

class TabBarItem: UIView {
    
    // UIImage(systemName: tempTabsIcons[i] + (selectedTab == i ? ".fill" : ""))
    let icon: UIImageView = {
        let icon = UIImageView()
        icon.tintColor = .fg
        icon.contentMode = .scaleAspectFill
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        return icon
    }()
    
    let label = TitleLabel("", style: .caption)
    
    init(label: String, icon: UIImage?) {
        super.init(frame: .zero)
        
        configure()
        setupConstraints()
        updateData(label: label, icon: icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        
        addSubview(icon)
        addSubview(label)
        
        label.alpha = 1.0
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44),

            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: icon.centerXAnchor)
        ])
    }
    
    func updateData(label: String, icon: UIImage?) {
        self.icon.image = icon
        self.label.text = label
    }
}
