import Architecture
import Info
import SharedModels
import UIKit
import ViewComponents

class SearchCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        self.dataSource = self
        self.delegate = self
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

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewCell.identifier, for: indexPath) as! SearchViewCell
        // swiftlint:enable force_cast
        let searchData = searchResults.results[indexPath.item]
        cell.configure(with: searchData)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard kind == UICollectionView.elementKindSectionFooter else {
            return UICollectionReusableView()
        }

        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SearchFooterLoadingView.identifier,
            for: indexPath
        )

        return footer
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}
