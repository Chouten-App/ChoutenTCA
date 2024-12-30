//
//  SeasonDisplay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 08.02.24.
//

import Core
import UIKit

protocol SeasonDisplayDelegate: AnyObject {
    func didChangePagination(to: Int)
}

class SeasonDisplay: UIView {

    weak var delegate: SeasonDisplayDelegate?
    var infoData: InfoData
    var selectedPagination: Int = 0

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let seasonLabel: UILabel = {
        let label = UILabel()
        label.text = "Season 1"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    let seasonButton = CircleButton(icon: "chevron.right")

    let mediaCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Media"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.alpha = 0.7
        return label
    }()

    let pagination = PaginationDisplay()

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
        horizontalStack.addArrangedSubview(seasonLabel)
        horizontalStack.addArrangedSubview(seasonButton)

        stack.addArrangedSubview(horizontalStack)
        stack.addArrangedSubview(mediaCountLabel)
        stack.addArrangedSubview(pagination)

        addSubview(stack)
        pagination.delegate = self
    }

    func updateData() {
        if infoData.mediaList.count > selectedPagination {
            mediaCountLabel.text = "\(infoData.mediaList[selectedPagination].pagination.first?.items.count ?? 0) \(infoData.mediaType)"
        }
        seasonLabel.text = infoData.seasons.first(where: { $0.selected == true })?.name
        pagination.infoData = infoData
        pagination.updateData()
    }

    // MARK: Layout

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        if !infoData.tags.isEmpty {
            NSLayoutConstraint.activate([
                pagination.heightAnchor.constraint(equalToConstant: 24),
                pagination.topAnchor.constraint(equalTo: mediaCountLabel.bottomAnchor, constant: 8)
            ])
        }
    }
}

extension SeasonDisplay: PaginationDelegate {
    func didChangePagination(to index: Int) {
        selectedPagination = index
        if infoData.mediaList.count > selectedPagination {
            mediaCountLabel.text = "\(infoData.mediaList[selectedPagination].pagination.first?.items.count ?? 0) \(infoData.mediaType)"
        }
        delegate?.didChangePagination(to: index)
    }
}
