//
//  AppFeature+VC.swift
//  App
//
//  Created by Inumaki on 11.03.24.
//

import Architecture
import DataClient
import Discover
import Home
import Repo
import Search
import Settings
import SharedModels
import UIKit
import ViewComponents

public class AppViewController: UIViewController {
    var module: Module?
    var store: Store<AppFeature.State, AppFeature.Action>
    var repoStore: Store<RepoFeature.State, RepoFeature.Action>

    let tabs: [UIViewController]

    let topBar = AppViewTopBar()
    let tabBar = CustomTabbar()
    let moduleSelector = ModalViewController()

    var selectedTab: Int = 0

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    public init(_ module: Module?) {
        self.module = module

        self.repoStore = .init(
            initialState: .init(),
            reducer: { RepoFeature() }
        )
        self.tabs = [
            HomeView(),
            DiscoverView(),
            RepoView(
                store: repoStore
            )
        ]

        store = .init(
            initialState: .init(),
            reducer: { AppFeature() }
        )
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(forName: .changedModule, object: nil, queue: nil) { notification in
            if let result = notification.object as? Module {
                // Handle the result here
                print("Received result from notification: \(result)")
                self.moduleSelector.selectedModuleTitle.text = result.name
            } else {
                print("Notification received without a valid result.")
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        for index in 0..<tabs.count {
            let tab = tabs[index]
            tab.view.tag = index
            tab.view.alpha = selectedTab == index ? 1.0 : 0.0
            addChild(tab)
            view.addSubview(tab.view)
        }

        configure()
        setupConstraints()

        if let discoverView = tabs[1] as? DiscoverView {
            discoverView.scrollView.delegate = self
        }

        observe { [weak self] in
            guard let self else { return }

            self.topBar.label.text = store.selected.rawValue

            switch store.selected {
            case .home:
                self.topBar.settingsImage.image = UIImage(named: "pfp")
            case .discover:
                self.topBar.settingsImage.tintColor = ThemeManager.shared.getColor(for: .fg)
                self.topBar.settingsImage.image = UIImage(systemName: "magnifyingglass")?
                    .withRenderingMode(.alwaysTemplate)
                    .applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 12)))
            case .repos:
                self.topBar.settingsImage.tintColor = ThemeManager.shared.getColor(for: .fg)
                self.topBar.settingsImage.image = UIImage(systemName: "plus")?
                    .withRenderingMode(.alwaysTemplate)
                    .applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 12)))
            }
        }

        store.send(.view(.onAppear))
    }

    private func configure() {
        moduleSelector.selectedModuleTitle.text = module?.name

        addChild(moduleSelector)
        view.addSubview(moduleSelector.view)

        tabBar.delegate = self
        topBar.delegate = self
        tabBar.isUserInteractionEnabled = true
        topBar.isUserInteractionEnabled = true
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)
        view.addSubview(topBar)
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            // ModuleSelector constraints
            moduleSelector.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 12), // Adjusted to -14 for spacing
            moduleSelector.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            moduleSelector.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),

            // TabBar constraints
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: max(bottomPadding + 52, 72)),

            // TopBar constraints
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.heightAnchor.constraint(equalToConstant: max(topPadding + 64, 72))
        ])

    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        for tab in tabs {
            tab.removeFromParent()
        }
    }
}

extension AppViewController: CustomTabbarDelegate {
    // animation helper function
    func animate(closure: @escaping () -> Void) {
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            closure()
        })
    }

    public func didSelectTab(_ tab: Int) {
        let offset: CGFloat = 60

        let oldTabIndex = selectedTab
        if oldTabIndex == tab { return }

        selectedTab = tab

        // Sending the store update for the new tab
        switch tab {
        case 0:
            store.send(.view(.changeTab(.home)))
        case 1:
            store.send(.view(.changeTab(.discover)))
        case 2:
            store.send(.view(.changeTab(.repos)))
        case _:
            store.send(.view(.changeTab(.home)))
        }

        // Animate the tab transitions
        for index in 0..<tabs.count {
            let tab = tabs[index]

            if index == oldTabIndex {
                // Animate the old tab out
                switch index {
                case 0:
                    // if moving from home to smth
                    animate {
                        tab.view.alpha = 0.0
                        tab.view.transform = CGAffineTransform(translationX: -offset, y: 0)
                    }
                case 1:
                    if selectedTab == 0 {
                        // if moving from discover to home
                        animate {
                            tab.view.alpha = 0.0
                            tab.view.transform = CGAffineTransform(translationX: offset, y: 0)
                        }
                    } else if selectedTab == 2 {
                        // if moving from discover to repo
                        animate {
                            tab.view.alpha = 0.0
                            tab.view.transform = CGAffineTransform(translationX: -offset, y: 0)
                        }
                    }
                case 2:
                    // if moving from repo to smth
                    animate {
                        tab.view.alpha = 0.0
                        tab.view.transform = CGAffineTransform(translationX: offset, y: 0)
                    }
                default:
                    break
                }
            } else if index == selectedTab {
                // Animate the new tab in
                tab.view.alpha = 0.0
                switch index {
                case 0:
                    // if moving to home from smth
                    tab.view.transform = CGAffineTransform(translationX: -offset, y: 0)
                case 1:
                    if oldTabIndex == 0 {
                        // if moving to discover from home
                        tab.view.transform = CGAffineTransform(translationX: offset, y: 0)

                    } else if oldTabIndex == 2 {
                        // if moving from discover to repo
                        tab.view.transform = CGAffineTransform(translationX: -offset, y: 0)
                    }

                case 2:
                    // if moving from repo to smtha
                    tab.view.transform = CGAffineTransform(translationX: offset, y: 0)
                default:
                    break
                }
                animate {
                    tab.view.alpha = 1.0
                    tab.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }
            } else {
                // Ensure other tabs are hidden
                tab.view.alpha = 0.0
                tab.view.transform = CGAffineTransform.identity
            }
        }
    }
}

extension AppViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y - 100

        topBar.blurView.alpha = -offsetY / 60
    }
}

extension AppViewController: AppViewTopBarDelegate {
    public func didTapButton() {
        let scenes = UIApplication.shared.connectedScenes

        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        var vc: UIViewController
        switch store.state.selected {
        case .home:
            // open popup
            vc = SettingsView()
            let popoverController = vc.popoverPresentationController
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = self.view.bounds
            popoverController?.permittedArrowDirections = .any
            popoverController?.delegate = self

            navController.present(vc, animated: true, completion: nil)
        case .discover:
            vc = SearchView()

            navController.navigationBar.isHidden = true

            navController.pushViewController(vc, animated: true)
        case .repos:
            vc = RepoInstallPopup(store: self.repoStore)

            let popoverController = vc.popoverPresentationController
            popoverController?.sourceView = self.view
            popoverController?.sourceRect = self.view.bounds
            popoverController?.permittedArrowDirections = .any
            popoverController?.delegate = self

            navController.present(vc, animated: true, completion: nil)
        }
    }
}

extension AppViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
