//
//  NextChapterCell.swift
//  Book
//
//  Created by Inumaki on 20.07.24.
//

import Architecture
import UIKit

class ChapterFooterCell: UICollectionViewCell {
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

    let chapterCompleted: UILabel = {
        let label = UILabel()
        label.text = "Chapter completed"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nowReading: UILabel = {
        let label = UILabel()
        label.text = "Now reading"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let newChapterLabel: UILabel = {
        let label = UILabel()
        label.text = "Chapter 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(oldChapterLabel)
        contentView.addSubview(chapterCompleted)
        contentView.addSubview(nowReading)
        contentView.addSubview(newChapterLabel)

        NSLayoutConstraint.activate([
            oldChapterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            chapterCompleted.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nowReading.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            newChapterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            oldChapterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -80),
            chapterCompleted.topAnchor.constraint(equalTo: oldChapterLabel.bottomAnchor, constant: 8),
            nowReading.bottomAnchor.constraint(equalTo: newChapterLabel.topAnchor, constant: -8),
            newChapterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 80)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ newChapterTitle: String, oldChapterTitle: String) {
        newChapterLabel.text = newChapterTitle
        oldChapterLabel.text = oldChapterTitle
    }
}
