//
//  EmptySectionFooter.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//

import UIKit

class EmptySectionFooter: UICollectionReusableView {
    static let reuseIdentifier = "EmptySectionFooter"

    private let card = TitleCard("No items available.", description: "You don't have any items in this collection.")

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(card)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
