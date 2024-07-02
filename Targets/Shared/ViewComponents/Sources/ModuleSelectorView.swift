//
//  ModuleSelectorView.swift
//  ViewComponents
//
//  Created by Inumaki on 25.06.24.
//

import Architecture
import ComposableArchitecture
import RepoClient
import SharedModels
import UIKit

public class ModuleSelectorView: UIViewController, UIScrollViewDelegate, ModuleCardDelegate {
    @Dependency(\.repoClient) var repoClient

    let scrollView: UIScrollView = {
        let scrollView                              = UIScrollView()
        scrollView.alwaysBounceVertical             = true
        scrollView.showsVerticalScrollIndicator     = false
        scrollView.contentInsetAdjustmentBehavior   = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let stack           = UIStackView()
        stack.axis          = .vertical
        stack.spacing       = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let repoSwitcherScroll: UIScrollView = {
        let scrollView                              = UIScrollView()
        scrollView.alwaysBounceHorizontal           = true
        scrollView.isPagingEnabled                  = true
        scrollView.clipsToBounds                    = false
        scrollView.showsHorizontalScrollIndicator   = false
        scrollView.contentInsetAdjustmentBehavior   = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let repoSwitcherContent: UIStackView = {
        let stack           = UIStackView()
        stack.axis          = .horizontal
        stack.spacing       = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    var repos: [RepoMetadata] = []
    var currentRepoId: String?

    override public func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setupConstraints()

        repoSwitcherScroll.delegate = self
        loadRepos()
    }

    private func configure() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addArrangedSubview(repoSwitcherScroll)
        repoSwitcherScroll.addSubview(repoSwitcherContent)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            repoSwitcherScroll.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            repoSwitcherScroll.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            repoSwitcherScroll.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            repoSwitcherScroll.heightAnchor.constraint(equalToConstant: 130), // Adjusted height for visibility

            repoSwitcherContent.topAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.topAnchor),
            repoSwitcherContent.bottomAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.bottomAnchor),
            repoSwitcherContent.leadingAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.leadingAnchor),
            repoSwitcherContent.trailingAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.trailingAnchor)
        ])
    }

    private func loadRepos() {
        // let moduleId = UserDefaults.standard.string(forKey: "selectedModuleId")

        do {
            repos = try repoClient.getRepos()

            for repo in repos {
                let repoHeader = RepoSelectorHeader(repo)
                repoSwitcherContent.addArrangedSubview(repoHeader)

                NSLayoutConstraint.activate([
                    repoHeader.widthAnchor.constraint(equalTo: repoSwitcherScroll.frameLayoutGuide.widthAnchor)
                ])
            }

            // Load initial modules for the first repo if any
            if let firstRepo = repos.first {
                loadModules(for: firstRepo)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    private func loadModules(for repo: RepoMetadata) {
        do {
            print("Loading modules for: \(repo.id)")
            let modules = try repoClient.getModulesForRepo(id: repo.id)

            // Clear existing modules
            contentView.arrangedSubviews.forEach { view in
                if view !== repoSwitcherScroll {
                    UIView.animate(withDuration: 0.2) {
                        self.contentView.removeArrangedSubview(view)
                        view.removeFromSuperview()
                    }
                }
            }

            // Add new modules
            let modulesTitle = UILabel()
            modulesTitle.text = "Modules"
            modulesTitle.font = .systemFont(ofSize: 18, weight: .bold)
            modulesTitle.textColor = ThemeManager.shared.getColor(for: .fg)

            contentView.addArrangedSubview(modulesTitle)

            let selectedModuleId = UserDefaults.standard.string(forKey: "selectedModuleId")

            for module in modules {
                let moduleCard = ModuleCard(module, id: repo.id, selector: true)
                moduleCard.delegate = self
                moduleCard.layer.borderColor = ThemeManager.shared.getColor(for: module.id == selectedModuleId ? .accent : .border).cgColor
                UIView.animate(withDuration: 0.2) {
                    self.contentView.addArrangedSubview(moduleCard)
                }
            }

            currentRepoId = repo.id
        } catch {
            print(error.localizedDescription)
        }
    }

    public func updateSelectedModule(id: String) {
        UserDefaults.standard.setValue(id, forKey: "selectedModuleId")
        contentView.arrangedSubviews.forEach { view in
            if let moduleCard = view as? ModuleCard {
                moduleCard.layer.borderColor = ThemeManager.shared.getColor(for: moduleCard.module.id == id ? .accent : .border).cgColor
            }
        }
        NotificationCenter.default.post(name: .updatedSelectedModule, object: nil)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == repoSwitcherScroll else { return }

        let centeredIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)

        print(centeredIndex)

        if centeredIndex < repos.count {
            let centeredRepo = repos[centeredIndex]

            if centeredRepo.id != currentRepoId {
                loadModules(for: centeredRepo)
            }
        }
    }
}
