//
//  SearchCard.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.03.24.
//

import Architecture
import Nuke
import SharedModels
import UIKit

public class SearchCard: UIView {
    public var data: SearchData

    public init(data: SearchData) {
        self.data = data
        super.init(frame: .zero)
        configure()
        setConstraints()
        updateData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let mainView = UIView()
    let imageView = UIImageView()

    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let innerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let indicator = UIView()

    let indicatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private func configure() {
        mainView.backgroundColor = UIColor.itemBG
        mainView.layer.cornerRadius = 8
        mainView.clipsToBounds = true
        mainView.layer.borderWidth = 0.5
        mainView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        mainView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(imageView)

        indicator.backgroundColor = UIColor.circleBG
        indicator.layer.cornerRadius = 12
        indicator.clipsToBounds = true
        indicator.layer.borderWidth = 0.5
        indicator.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.addSubview(indicatorLabel)
        mainView.addSubview(indicator)

        stack.addArrangedSubview(mainView)

        innerStack.addArrangedSubview(titleLabel)
        innerStack.addArrangedSubview(countLabel)

        stack.addArrangedSubview(innerStack)

        addSubview(stack)
    }

    private func setConstraints() {
        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(equalToConstant: 110),

            mainView.widthAnchor.constraint(equalToConstant: 110),
            mainView.heightAnchor.constraint(equalToConstant: 150),

            imageView.widthAnchor.constraint(equalTo: mainView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: mainView.heightAnchor),

            indicator.widthAnchor.constraint(equalTo: indicatorLabel.widthAnchor, constant: 16), // Add some padding if needed
            indicator.heightAnchor.constraint(equalTo: indicatorLabel.heightAnchor, constant: 8),
            indicator.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -8),
            indicator.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 8),

            indicatorLabel.trailingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: -8),
            indicatorLabel.topAnchor.constraint(equalTo: indicator.topAnchor, constant: 4)
        ])
    }

    public func updateData() {
        // Assuming SearchData properties match SectionCard properties

        let imageUrlString = data.img
        if let imageUrl = URL(string: imageUrlString) {
            ImagePipeline.shared.loadImage(with: imageUrl) { result in
                do {
                    let imageResponse = try result.get()
                    self.imageView.image = imageResponse.image
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        titleLabel.text = data.title
        countLabel.text = "\(data.currentCount)/\(data.totalCount)"
        indicatorLabel.text = data.indicatorText
    }
}
