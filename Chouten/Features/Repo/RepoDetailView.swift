//
//  RepoDetailView.swift
//  Repo
//
//  Created by Inumaki on 11.06.24.
//

import Dependencies
import ComposableArchitecture
import UIKit

class ModuleTapGestureRecognizer: UITapGestureRecognizer {
    var moduleId: String?
}

protocol RepoDetailDelegate: AnyObject {
    func refreshRepo()
}

// swiftlint:disable type_body_length
class RepoDetailView: UIViewController {
    @Dependency(\.repoClient) var repoClient

    var repo: RepoMetadata

    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical             = true
        view.contentInsetAdjustmentBehavior   = .never
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .top
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let titleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let topPart: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .bottom
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let repoPicture: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pfp")
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        imageView.layer.cornerRadius = 12
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Repo Title"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let authorLabel: UILabel = {
        let label = UILabel()
        label.text = "Author"
        label.font = .systemFont(ofSize: 16)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .systemFont(ofSize: 14)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let installedModuleStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 12
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let installedTitle: UILabel = {
        let label = UILabel()
        label.text = "INSTALLED"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let installedNumber: UILabel = {
        let label = UILabel()
        label.text = "5"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let availableModuleStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 12
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let availableTitle: UILabel = {
        let label = UILabel()
        label.text = "AVAILABLE"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let availableNumber: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let backButton = CircleButton(icon: "chevron.left")
    let refreshButton = CircleButton(icon: "arrow.triangle.2.circlepath")

    init(_ repo: RepoMetadata) {
        self.repo = repo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setupConstraints()
    }

    private func getInstalledModules() -> [Module] {
        let fileManager = FileManager.default

        // Get the path to the user's Documents directory
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not locate the Documents directory.")
            return []
        }

        // Append the "Repos" folder to the path
        let reposDirectory = documentsDirectory
            .appendingPathComponent("Repos")
            .appendingPathComponent(repo.id)
            .appendingPathComponent("Modules")

        do {
            // Get the list of all items in the "Repos" directory
            let items = try fileManager.contentsOfDirectory(at: reposDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

            var repoArray: [Module] = []
            for item in items {
                var isDirectory: ObjCBool = false

                // Check if the item is a directory
                if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory), isDirectory.boolValue {
                    // Construct the path to the "metadata.json" file
                    let metadataFilePath = item.appendingPathComponent("metadata.json")

                    if fileManager.fileExists(atPath: metadataFilePath.path) {
                        do {
                            // Read the contents of the "metadata.json" file
                            let jsonData = try Data(contentsOf: metadataFilePath)

                            // Convert the JSON data to a string for printing
                            let repo = try JSONDecoder().decode(Module.self, from: jsonData)

                            repoArray.append(repo)
                            print("Loaded Module \(repo.id)")
                        } catch {
                            print("Failed to read JSON file at path: \(metadataFilePath.path), error: \(error)")
                        }
                    } else {
                        print("No metadata.json file found in directory: \(item.path)")
                    }
                }
            }
            return repoArray
        } catch {
            print("Failed to list contents of directory: \(reposDirectory.path), error: \(error)")
        }

        return []
    }

    private func configure() {
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let imageUrl = documentsDirectory?.appendingPathComponent("Repos").appendingPathComponent(repo.id).appendingPathComponent("icon.png") {
            let imageData = try? Data(contentsOf: imageUrl)

            if let imageData {
                let image = UIImage(data: imageData)

                repoPicture.image = image
            }
        }
        titleLabel.text = repo.title
        authorLabel.text = repo.author
        descriptionLabel.text = repo.description

        topPart.addArrangedSubview(repoPicture)
        titleStack.addArrangedSubview(authorLabel)
        titleStack.addArrangedSubview(titleLabel)
        topPart.addArrangedSubview(titleStack)

        contentView.addArrangedSubview(topPart)
        contentView.addArrangedSubview(descriptionLabel)
        contentView.addArrangedSubview(installedTitle)
        contentView.addArrangedSubview(installedModuleStack)
        contentView.addArrangedSubview(availableTitle)
        contentView.addArrangedSubview(availableModuleStack)

        scrollView.addSubview(contentView)

        view.addSubview(scrollView)
        view.addSubview(backButton)
        view.addSubview(refreshButton)

        backButton.onTap = {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        }

        refreshButton.onTap = {
            Task {
                if let urlString = self.repo.url,
                   let url = URL(string: urlString) {
                    var newRepoMetadata = try await self.repoClient.fetchRepoDetails(url: url)
                    if var newRepoMetadata {
                        newRepoMetadata.url = self.repo.url
                        self.repo = newRepoMetadata
                        self.updateData()
                    }
                }
            }
        }

        let installedModules = getInstalledModules()
        let installedModuleIds = Set(installedModules.map { $0.id })

        for index in 0..<installedModules.count {
            var module = installedModules[index]

            // check if new version exists
            if let availableVersion = repo.modules?.first(where: { $0.id == module.id })?.version {
                switch module.version.compare(availableVersion, options: .numeric) {
                case .orderedSame:
                    module.state = .upToDate
                case .orderedDescending:
                    // available is lower
                    module.state = .upToDate
                case .orderedAscending:
                    module.state = .updateAvailable
                }
            }

            let moduleCard = ModuleCard(module, id: repo.id)
            installedModuleStack.addArrangedSubview(moduleCard)
        }

        if installedModules.isEmpty {
            let noInstalledModules = TitleCard(
                "No modules installed.",
                description: "You don't have any modules installed yet."
            )
            installedModuleStack.addArrangedSubview(noInstalledModules)
        }

        let loadingCard = TitleCard(
            "Looking for modules...",
            description: "Loading all available modules from the repo."
        )

        if let modules = repo.modules {
            let availableModules = modules.filter { !installedModuleIds.contains($0.id) }
            
            if availableModules.count == 0 {
                // Add TitleCard component
                let noAvailableModulesCard = TitleCard(
                    "No uninstalled modules for this repo",
                    description: "All available modules are already installed."
                )
                availableModuleStack.addArrangedSubview(noAvailableModulesCard)
            }
            
            for availableModule in availableModules {
                let convertedModule = Module(
                    id: availableModule.id,
                    name: availableModule.name,
                    author: availableModule.author,
                    description: "N/A",
                    type: 0,
                    subtypes: availableModule.subtypes,
                    version: availableModule.version,
                    state: .notInstalled
                )
                let moduleCard = ModuleCard(convertedModule, id: repo.id)

                let tapGesture = ModuleTapGestureRecognizer(target: self, action: #selector(installModule(_:)))
                tapGesture.moduleId = availableModule.id
                moduleCard.isUserInteractionEnabled = true
                moduleCard.addGestureRecognizer(tapGesture)

                availableModuleStack.addArrangedSubview(moduleCard)
            }
        } else {
            availableModuleStack.addArrangedSubview(loadingCard)
        }
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            repoPicture.widthAnchor.constraint(equalToConstant: 100),
            repoPicture.heightAnchor.constraint(equalToConstant: 100),

            topPart.heightAnchor.constraint(equalToConstant: topPadding + 200),

            descriptionLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

            availableModuleStack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 40),

            refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            refreshButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 40)
        ])
    }

    func updateData() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let imageUrl = documentsDirectory?.appendingPathComponent("Repos").appendingPathComponent(repo.id).appendingPathComponent("icon.png") {
            let imageData = try? Data(contentsOf: imageUrl)

            if let imageData {
                let image = UIImage(data: imageData)

                repoPicture.image = image
            }
        }
        titleLabel.text = repo.title
        authorLabel.text = repo.author
        descriptionLabel.text = repo.description

        installedModuleStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        availableModuleStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let loadingCard = TitleCard(
            "Looking for modules...",
            description: "Loading all available modules from the repo."
        )

        if let modules = repo.modules {
            for availableModule in modules {
                let convertedModule = Module(
                    id: availableModule.id,
                    name: availableModule.name,
                    author: availableModule.author,
                    description: "N/A",
                    type: 0,
                    subtypes: availableModule.subtypes,
                    version: availableModule.version,
                    state: .notInstalled
                )
                let moduleCard = ModuleCard(convertedModule, id: repo.id)

                let tapGesture = ModuleTapGestureRecognizer(target: self, action: #selector(installModule(_:)))
                tapGesture.moduleId = availableModule.id
                moduleCard.isUserInteractionEnabled = true
                moduleCard.addGestureRecognizer(tapGesture)

                availableModuleStack.addArrangedSubview(moduleCard)
            }
        } else {
            availableModuleStack.addArrangedSubview(loadingCard)
        }

        let installedModules = getInstalledModules()
        for index in 0..<installedModules.count {
            var module = installedModules[index]

            // check if new version exists
            if let availableVersion = repo.modules?.first { $0.id == module.id }?.version {
                switch module.version.compare(availableVersion, options: .numeric) {
                case .orderedSame:
                    module.state = .upToDate
                case .orderedDescending:
                    // available is lower
                    // should never happen, but is possible
                    module.state = .upToDate
                case .orderedAscending:
                    module.state = .updateAvailable
                }
            }

            let moduleCard = ModuleCard(module, id: repo.id)

            installedModuleStack.addArrangedSubview(moduleCard)
        }
        if installedModules.isEmpty {
            let noInstalledModules = TitleCard(
                "No modules installed.",
                description: "You don't have any modules installed yet."
            )

            installedModuleStack.addArrangedSubview(noInstalledModules)
        }
    }

    @objc func installModule(_ sender: ModuleTapGestureRecognizer) {
        guard let moduleId = sender.moduleId else { return }

        Task {
            do {
                try await repoClient.installModule(repo, moduleId)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
// swiftlint:enable type_body_length
