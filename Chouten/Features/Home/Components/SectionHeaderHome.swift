//
//  SectionHeader.swift
//  Home
//
//  Created by Inumaki on 13.07.24.
//

import UIKit
import Combine
import ComposableArchitecture

class SectionHeaderHome: UICollectionReusableView {
    static let reuseIdentifier: String = "SectionHeaderHome"

    let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let deleteButton = CircleButton(icon: "trash");
    
    var onDelete: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        addSubview(deleteButton)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])
        
        deleteButton.isHidden = true
        deleteButton.tintColor = UIColor(.red)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func deleteTapped() {
        onDelete?()
    }
    
    func configure(with title: String) {
        label.text = title
    }
}
