//
//  SearchCollectionView.swift
//  Chouten
//
//  Created by Inumaki on 06.03.24.
//

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
        self.register(SectionCardCell.self, forCellWithReuseIdentifier: "SearchCell")

        layout.itemSize = CGSize(width: 110, height: 190) // Square cells
        layout.minimumInteritemSpacing = 1 // Horizontal spacing between cells
        layout.minimumLineSpacing = 20 // Vertical spacing between cells
        layout.scrollDirection = .vertical // Scroll direction

        self.backgroundColor = ThemeManager.shared.getColor(for: .bg) // Set background color
        self.showsVerticalScrollIndicator = false // Hide vertical scroll indicator
        self.showsHorizontalScrollIndicator = false // Hide horizontal scroll indicator
        self.collectionViewLayout = layout // Set custom layout

        print("collection view initialized")
    }

    // Custom initializer
//    convenience init(layout: UICollectionViewFlowLayout) {
//        self.init(frame: .zero, collectionViewLayout: layout)
//
//        self.clipsToBounds = false
//        self.dataSource = self
//        self.delegate = self
//        self.register(SectionCardCell.self, forCellWithReuseIdentifier: "SearchCell")
//
//        layout.itemSize = CGSize(width: 110, height: 190) // Square cells
//        layout.minimumInteritemSpacing = 1 // Horizontal spacing between cells
//        layout.minimumLineSpacing = 20 // Vertical spacing between cells
//        layout.scrollDirection = .vertical // Scroll direction
//        self.alwaysBounceVertical = true
//
//        self.backgroundColor = ThemeManager.shared.getColor(for: .bg) // Set background color
//        self.showsVerticalScrollIndicator = false // Hide vertical scroll indicator
//        self.showsHorizontalScrollIndicator = false // Hide horizontal scroll indicator
//        self.collectionViewLayout = layout // Set custom layout
//
//        print("collection view initialized (conv)")
//    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        self.searchResults = SearchResult(info: SearchResultInfo(pages: 0), results: [])
        super.init(frame: frame, collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        searchResults.results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SectionCardCell
        // swiftlint:enable force_cast
        let searchData = searchResults.results[indexPath.item]
        cell.configure(with: searchData)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("pressed \(indexPath.item)")
//        guard let cell = collectionView.cellForItem(at: indexPath) as? SectionCardCell else { return }
//
//        let viewcontroller = InfoViewRefactor(url: searchResults.data[indexPath.item].url)
//
//        guard let window = UIApplication.shared.windows.first,
//              let navController = window.rootViewController as? UINavigationController else {
//            return
//        }
//
//        navController.present(viewcontroller, animated: true)
    }
}

class SectionCardCell: UICollectionViewCell {
    let sectionCard: SearchCard
    var data: SearchData

    init(data: SearchData) {
        self.data = data
        sectionCard = SearchCard(data: data)
        super.init(frame: .zero)
    }

    override init(frame: CGRect) {
        self.data = .sample
        sectionCard = SearchCard(data: .sample)
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with searchData: SearchData) {
        self.isUserInteractionEnabled = true
        self.data = searchData
        sectionCard.data = searchData

        contentView.addSubview(sectionCard)
        sectionCard.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 200),

            sectionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sectionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sectionCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            sectionCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        sectionCard.updateData()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigateToInfo))
        tapRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(tapRecognizer)
    }

    @objc func navigateToInfo() {
        print("pressed")
        let scenes = UIApplication.shared.connectedScenes

        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        let tempVC = InfoViewRefactor(url: data.url)
        navController.navigationBar.isHidden = true
        navController.pushViewController(tempVC, animated: true)
    }
}
