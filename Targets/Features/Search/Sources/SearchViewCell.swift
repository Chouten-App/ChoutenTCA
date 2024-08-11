//
//  SearchViewCell.swift
//  Search
//
//  Created by Inumaki on 04.07.24.
//

import Info
import SharedModels
import UIKit
import ViewComponents

final class SearchViewCell: UICollectionViewCell {
    static let identifier = "SearchViewCell"

    let sectionCard: SearchCard
    var data: SearchData?

    init(data: SearchData) {
        self.data = data
        sectionCard = SearchCard(data: data)
        super.init(frame: .zero)
    }

    override init(frame: CGRect) {
        self.data = nil
        sectionCard = SearchCard(data: nil)
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
        if let data {
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
}
