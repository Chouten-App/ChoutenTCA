//
//  ContainerView.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import UIKit

class ContainerView: UIView {
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
        
        backgroundColor = .container
        layer.borderColor = UIColor.border.cgColor
        layer.borderWidth = 0.5

        layer.cornerRadius = 12
    }
    
    private func setupConstraints() {}
}
