//
//  SearchFooterLoadingView.swift
//  Search
//
//  Created by Inumaki on 04.07.24.
//

import UIKit

final class SearchFooterLoadingView: UICollectionReusableView {
    static let identifier = "SearchFooterLoadingView"

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {}
}
