//
//  SectionList.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 30.01.24.
//

import Architecture
import SharedModels
import UIKit

public class SectionList: UIView {
    let section: DiscoverSection

    override public init(frame: CGRect) {
        self.section = .init(title: "", list: [])
        super.init(frame: frame)
        configure()
        setConstraints()
    }

    public required init?(coder: NSCoder) {
        self.section = .init(title: "", list: [])
        super.init(coder: coder)
        configure()
        setConstraints()
    }

    public init(section: DiscoverSection) {
        self.section = section
        super.init(frame: .zero)
        configure()
        setConstraints()
    }

    public let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Section"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.clipsToBounds = false
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    public let scrollViewContent: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private func configure() {
        scrollView.addSubview(scrollViewContent)

        stack.addArrangedSubview(sectionTitleLabel)
        stack.addArrangedSubview(scrollView)

        addSubview(stack)

        sectionTitleLabel.text = section.title
    }

    public weak var delegate: SectionListDelegate?

    private func setConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            // scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            // scrollView.widthAnchor.constraint(equalTo: widthAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 200),
            // scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),

            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -60),
            scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContent.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        for index in 0..<section.list.count {
            let card = SectionCard(data: section.list[index])

            card.delegate = self

            scrollViewContent.addArrangedSubview(card)
            card.widthAnchor.constraint(equalToConstant: 110).isActive = true
        }
    }
}

extension SectionList: SectionCardDelegate {
    public func didTap(_ data: DiscoverData) {
        delegate?.didTap(data)
    }
}
