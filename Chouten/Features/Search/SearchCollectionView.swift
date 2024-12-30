//
//  SearchCollectionView.swift
//  Chouten
//
//  Created by Inumaki on 06/11/2024.
//

import Core
import UIKit

class SearchCollectionView: UICollectionView {
    var searchResults: SearchResult {
        didSet {
            reloadData()
        }
    }

    // Define the number of columns
    let numberOfColumns: CGFloat = 3

    init(result: SearchResult, layout: UICollectionViewFlowLayout) {
        self.searchResults = result
        super.init(frame: .zero, collectionViewLayout: layout)

        self.clipsToBounds = false
        self.isUserInteractionEnabled = true
        self.register(SearchViewCell.self, forCellWithReuseIdentifier: SearchViewCell.identifier)
        self.register(
            SearchFooterLoadingView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: SearchFooterLoadingView.identifier
        )

        layout.itemSize = CGSize(width: 110, height: 190) // Square cells
        layout.minimumInteritemSpacing = 1 // Horizontal spacing between cells
        layout.minimumLineSpacing = 20 // Vertical spacing between cells
        layout.scrollDirection = .vertical // Scroll direction

        self.backgroundColor = ThemeManager.shared.getColor(for: .bg) // Set background color
        self.showsVerticalScrollIndicator = false // Hide vertical scroll indicator
        self.showsHorizontalScrollIndicator = false // Hide horizontal scroll indicator
        self.collectionViewLayout = layout // Set custom layout
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.searchResults = SearchResult(info: SearchResultInfo(pages: 0), results: [])
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
