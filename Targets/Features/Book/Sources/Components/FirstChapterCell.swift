//
//  FirstChapterCell.swift
//  Book
//
//  Created by Inumaki on 22.07.24.
//

import Architecture
import UIKit

class FirstChapterCell: UICollectionViewCell {
    let oldChapterLabel: UILabel = {
        let label = UILabel()
        label.text = "Chapter 0"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let alreadyAtStartLabel: UILabel = {
        let label = UILabel()
        label.text = "You are already on the first chapter"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(oldChapterLabel)
        contentView.addSubview(alreadyAtStartLabel)

        NSLayoutConstraint.activate([
            oldChapterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            alreadyAtStartLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            oldChapterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -8),
            alreadyAtStartLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 8),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ chapterTitle: String) {
        oldChapterLabel.text = chapterTitle
    }
}

