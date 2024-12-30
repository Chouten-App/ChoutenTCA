//
//  SearchFooterLoadingView.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import UIKit

final class SearchFooterLoadingView: UICollectionReusableView {
    static let identifier = "SearchFooterLoadingView"

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .red
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}
