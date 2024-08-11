//
//  ModuleCard.swift
//  ViewComponents
//
//  Created by Inumaki on 11.06.24.
//

import Architecture
import ComposableArchitecture
import SharedModels
import UIKit

public protocol ModuleCardDelegate: NSObject {
    func updateSelectedModule(id: String)
}

public class ModuleCard: UIView {
    let module: Module
    let repoId: String
    let selector: Bool

    weak var delegate: ModuleCardDelegate?

    let modulePicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = nil
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let title: UILabel = {
        let label = UILabel()
        label.text = "Repo Title"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let subtitle: UILabel = {
        let label = UILabel()
        label.text = "Author • https://localhost:5500"
        label.font = .systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let statusImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(
                .init(
                    font: .systemFont(ofSize: 10, weight: .bold)
                )
            )
        imageView.tintColor = ThemeManager.shared.getColor(for: .fg)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let statusWrapper: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init(_ module: Module, id: String, selector: Bool = false) {
        self.module = module
        self.repoId = id
        self.selector = selector
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        backgroundColor = ThemeManager.shared.getColor(for: .container)
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false

        // set data
        // Get the path to the user's Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let imageUrl = documentsDirectory?
            .appendingPathComponent("Repos")
            .appendingPathComponent(repoId)
            .appendingPathComponent("Modules")
            .appendingPathComponent(module.id) {

            if let jpgData = try? Data(contentsOf: imageUrl.appendingPathComponent("icon.jpg")) {
                let image = UIImage(data: jpgData)

                modulePicture.image = image
            } else if let pngData = try? Data(contentsOf: imageUrl.appendingPathComponent("icon.png")) {
                let image = UIImage(data: pngData)

                modulePicture.image = image
            }
        }

        let statusImageName: String = {
            switch self.module.state {
            case .upToDate:
                "checkmark"
            case .updateAvailable:
                "square.and.arrow.down"
            case .discontinued:
                "xmark"
            case .notInstalled:
                "plus"
            default:
                "plus"
            }
        }()

        statusImage.image = UIImage(systemName: statusImageName)?
            .withRenderingMode(.alwaysTemplate)
            .applyingSymbolConfiguration(
                .init(
                    font: .systemFont(ofSize: 10, weight: .bold)
                )
            )

        title.text = module.name
        subtitle.text = "\(module.author) • \(module.version)"

        addSubview(modulePicture)
        addSubview(title)
        addSubview(subtitle)

        if !selector {
            statusWrapper.addSubview(statusImage)
            addSubview(statusWrapper)
        }

        if selector {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            isUserInteractionEnabled = true
            addGestureRecognizer(tapGesture)
        }
    }

    private func setupConstraints() {

//        let heightConstraint = heightAnchor
//                        .constraint(equalToConstant: 80)
//        heightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

            modulePicture.leadingAnchor.constraint(equalTo: leadingAnchor, constant: selector ? 12 : 16),
            modulePicture.centerYAnchor.constraint(equalTo: centerYAnchor),
            modulePicture.widthAnchor.constraint(equalToConstant: 44),
            modulePicture.heightAnchor.constraint(equalToConstant: 44),

            title.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: modulePicture.trailingAnchor, constant: 8),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: modulePicture.trailingAnchor, constant: 8),
            subtitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        if !selector {
            NSLayoutConstraint.activate([
                statusImage.widthAnchor.constraint(equalToConstant: 10),
                statusImage.heightAnchor.constraint(equalToConstant: 10),
                statusImage.centerXAnchor.constraint(equalTo: statusWrapper.centerXAnchor),
                statusImage.centerYAnchor.constraint(equalTo: statusWrapper.centerYAnchor),

                statusWrapper.widthAnchor.constraint(equalToConstant: 20),
                statusWrapper.heightAnchor.constraint(equalToConstant: 20),
                statusWrapper.centerYAnchor.constraint(equalTo: centerYAnchor),
                statusWrapper.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ])
        }
    }

    @objc func handleTap() {
        delegate?.updateSelectedModule(id: module.id)
    }
}
