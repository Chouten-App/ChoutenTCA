//
//  SettingsGroup.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import UIKit

class SettingsGroup: UIView {
    let titleLabel = TitleLabel("Group", style: .subtitle)
    let container = ContainerView()
    
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
        
        addSubview(titleLabel)
        addSubview(container)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
}
