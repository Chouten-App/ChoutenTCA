//
//  AddCollectionFooter.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import UIKit

class AddCollectionFooter: UICollectionReusableView {
    static let reuseIdentifier = "AddCollectionFooter"

    private let button = CircleButton(icon: "plus")

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
