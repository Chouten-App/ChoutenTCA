//
//  ModuleSelectorView.swift
//  ViewComponents
//
//  Created by Inumaki on 25.06.24.
//

import Core
import ComposableArchitecture
import UIKit

class ModuleSelectorView: UIViewController, UIScrollViewDelegate, ModuleCardDelegate {
    @Dependency(\.repoClient) var repoClient
    
    private let effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.alpha = 0.0
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        setupConstraints()

        repoSwitcherScroll.delegate = self
        loadRepos()
    }
    
    let noModulesTitleCard = TitleCard("No repos installed", description: "Install one using the input field on the \"Discover\" Page or by clicking the \"Add to Chouten\" button on any Repo supported by Chouten")


    private func configure() {
        view.addSubview(effectView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addArrangedSubview(repoSwitcherScroll)
        contentView.addArrangedSubview(noModulesTitleCard)
        repoSwitcherScroll.addSubview(repoSwitcherContent)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // ScrollView constraints
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view and other constraints
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title card constraints
            noModulesTitleCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            noModulesTitleCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 35),
            noModulesTitleCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35),
            

            // RepoSwitcherScroll constraints
            repoSwitcherScroll.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            repoSwitcherScroll.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            repoSwitcherScroll.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            repoSwitcherScroll.heightAnchor.constraint(equalToConstant: 130),

            repoSwitcherContent.topAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.topAnchor),
            repoSwitcherContent.bottomAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.bottomAnchor),
            repoSwitcherContent.leadingAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.leadingAnchor),
            repoSwitcherContent.trailingAnchor.constraint(equalTo: repoSwitcherScroll.contentLayoutGuide.trailingAnchor)
        ])
    }
    private func loadRepos() {
        do {
            repos = try repoClient.getRepos()

            for repo in repos {
                noModulesTitleCard.isHidden = true
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
            print(modules)

            for module in modules {
                print(module)
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

    func updateSelectedModule(id: String) {
        UserDefaults.standard.setValue(id, forKey: "selectedModuleId")
        NotificationCenter.default.post(name: .selectedModuleChange, object: nil, userInfo: ["moduleId": id])
        
        contentView.arrangedSubviews.forEach { view in
            guard let moduleCard = view as? ModuleCard else { return }
            
            let isSelected = (moduleCard.module.id == id)
            
            // We’ll remove any old shape layers to avoid stacking them
            moduleCard.layer.sublayers?.removeAll(where: { $0.name == "SlidingBorderLayer" })
            
            if isSelected {
                // 1) Hide or reset the default border
                moduleCard.layer.borderWidth = 0
                
                // 2) Create a shape layer for the sliding border
                let shapeLayer = CAShapeLayer()
                shapeLayer.name = "SlidingBorderLayer" // so we can remove it in the future
                shapeLayer.path = UIBezierPath(
                    roundedRect: moduleCard.bounds,
                    cornerRadius: moduleCard.layer.cornerRadius
                ).cgPath
                
                // The stroke color = "accent" color
                let accentColor = ThemeManager.shared.getColor(for: .accent).cgColor
                shapeLayer.strokeColor = accentColor
                shapeLayer.fillColor = UIColor.clear.cgColor
                shapeLayer.lineWidth = 2
                
                // Initially, set strokeEnd to 0 (nothing drawn)
                shapeLayer.strokeStart = 0
                shapeLayer.strokeEnd = 0
                
                // 3) Animate the strokeEnd to 1 (full border)
                let animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = 0
                animation.toValue = 1
                animation.duration = 0.3 // Adjust as needed
                
                // Add layer + animation
                moduleCard.layer.addSublayer(shapeLayer)
                shapeLayer.add(animation, forKey: nil)
                
                // Ensure strokeEnd is 1 after animation completes
                shapeLayer.strokeEnd = 1
                
            } else {
                // If not selected, revert to default border
                moduleCard.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
                moduleCard.layer.borderWidth = 0.5
            }
        }
        
        NotificationCenter.default.post(name: .updatedSelectedModule, object: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == repoSwitcherScroll else { return }

        let centeredIndex = Int((scrollView.contentOffset.x / scrollView.frame.width).rounded())

        if centeredIndex < repos.count {
            let centeredRepo = repos[centeredIndex]

            if centeredRepo.id != currentRepoId {
                loadModules(for: centeredRepo)
            }
        }
    }
}
