//
//  PaginationDisplay.swift
//  ViewComponents
//
//  Created by Inumaki on 28.05.24.
//

import Architecture
import SharedModels
import UIKit

public protocol PaginationDelegate: AnyObject {
    func didChangePagination(to: Int)
}

class PaginationTapGesture: UITapGestureRecognizer {
    var pagination: Int?
}

class PaginationDisplay: UIView {

    public weak var delegate: PaginationDelegate?
    public var selectedPagination: Int = 0
    var infoData: InfoData

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.axis = .horizontal
        contentView.spacing = 8
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    // MARK: Lifecycle

    init(infoData: InfoData) {
        self.infoData = infoData
        super.init(frame: .zero)
        configure()
        setupConstraints()
        updateData()
    }

    // MARK: View Lifecycle

    override init(frame: CGRect) {
        self.infoData = .sample
        super.init(frame: frame)
        configure()
        setupConstraints()
        updateData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup

    private func configure() {
        scrollView.addSubview(contentView)

        addSubview(scrollView)
    }

    func updateData() {
        contentView.arrangedSubviews
            .forEach({ $0.removeFromSuperview() })

        for index in 0..<infoData.mediaList.count {
            let tag = infoData.mediaList[index]

            let tagView = UIView()
            tagView.backgroundColor = index == selectedPagination ? ThemeManager.shared.getColor(for: .accent) : ThemeManager.shared.getColor(for: .overlay)
            tagView.translatesAutoresizingMaskIntoConstraints = false

            tagView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            tagView.layer.borderWidth = index == selectedPagination ? 0.5 : 0.0
            tagView.layer.cornerRadius = 12
            tagView.clipsToBounds = true

            let label = UILabel()
            label.text = tag.title
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = ThemeManager.shared.getColor(for: .fg)
            label.translatesAutoresizingMaskIntoConstraints = false

            tagView.addSubview(label)

            contentView.addArrangedSubview(tagView)

            NSLayoutConstraint.activate([
                tagView.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width + 24),

                label.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: tagView.centerYAnchor)
            ])

            let tapGesture = PaginationTapGesture(target: self, action: #selector(changePagination(_ :)))
            tapGesture.pagination = index
            tagView.isUserInteractionEnabled = true
            tagView.addGestureRecognizer(tapGesture)
        }
    }

    @objc func changePagination(_ sender: PaginationTapGesture) {
        selectedPagination = sender.pagination ?? 0
        for index in 0..<contentView.arrangedSubviews.count {
            contentView.arrangedSubviews[index].backgroundColor = index == self.selectedPagination
                        ? ThemeManager.shared.getColor(for: .accent)
                        : ThemeManager.shared.getColor(for: .overlay)
            contentView.arrangedSubviews[index].layer.borderWidth = index == self.selectedPagination ? 0.5 : 0.0
        }
        delegate?.didChangePagination(to: selectedPagination)
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: heightAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
}
