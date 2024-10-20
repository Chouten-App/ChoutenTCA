//
//  AppFeature+VC.swift
//  App
//
//  Created by Inumaki on 11.03.24.
//

import ComposableArchitecture
import Network
import UIKit

 class AppViewController: UIViewController {
    var module: Module?
    var store: Store<AppFeature.State, AppFeature.Action>
    // var repoStore: Store<RepoFeature.State, RepoFeature.Action>

    let tabs: [UIViewController]

    // let topBar = AppViewTopBar()
    let tabBar = TabBar()
    // let moduleSelector = ModalViewController()

    let monitor = NWPathMonitor()

    var isOffline = false

    let offlineBanner: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let offlineTitle: UILabel = {
        let label = UILabel()
        label.text = "Offline"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var selectedTab: Int = 0

    override  var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override  var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

     init(_ module: Module?) {
        self.module = module

        /*
        self.repoStore = .init(
            initialState: .init(),
            reducer: { RepoFeature() }
        )*/
        
        self.tabs = [
            HomeView(),
            DiscoverView(),
            // RepoView(store: repoStore)
        ]

        store = .init(
            initialState: .init(),
            reducer: { AppFeature() }
        )

        super.init(nibName: nil, bundle: nil)
        /*
        NotificationCenter.default.addObserver(forName: .changedModule, object: nil, queue: nil) { notification in
            if let result = notification.object as? Module {
                // Handle the result here
                print("Received result from notification: \(result)")
                self.moduleSelector.selectedModuleTitle.text = result.name
            } else {
                print("Notification received without a valid result.")
            }
        }
         */

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)

        /*
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("User is online")
                self.isOffline = false
                DispatchQueue.main.async {
                    self.view.layoutIfNeeded()
                }
            } else {
                print("User is offline")
                self.isOffline = true
                DispatchQueue.main.async {
                    self.view.layoutIfNeeded()
                }
            }
        }
         */
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override  func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        // topBar.blurView.alpha = 0.0

        for index in 0..<tabs.count {
            let tab = tabs[index]
            tab.view.tag = index
            tab.view.alpha = selectedTab == index ? 1.0 : 0.0
            addChild(tab)
            view.addSubview(tab.view)
        }

        configure()
        setupConstraints()

        /*
        if let discoverView = tabs[1] as? DiscoverView {
            discoverView.collectionView.delegate = self
        }
         */

        observe { [weak self] in
            guard let self else { return }

            /*
             self.topBar.label.text = store.selected.rawValue

            switch store.selected {
            case .home:
                self.topBar.settingsImage.tintColor = ThemeManager.shared.getColor(for: .fg)
                self.topBar.settingsImage.image = UIImage(systemName: "person")?
                    .withRenderingMode(.alwaysTemplate)
                    .applyingSymbolConfiguration(.init(font: .systemFont(ofSize: 12)))
                // self.topBar.settingsImage.image = UIImage(named: "pfp")
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
             */
        }

        store.send(.view(.onAppear))
    }

    private func configure() {
        // moduleSelector.selectedModuleTitle.text = module?.name

        // addChild(moduleSelector)
        // view.addSubview(moduleSelector.view)

        tabBar.delegate = self
        // topBar.delegate = self
        tabBar.isUserInteractionEnabled = true
        // topBar.isUserInteractionEnabled = true
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        // topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)
        // view.addSubview(topBar)
        
        /*
        offlineBanner.addSubview(offlineTitle)
        view.addSubview(offlineBanner)
         */
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            // ModuleSelector constraints
            /*
            moduleSelector.view.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: 12), // Adjusted to -14 for spacing
            moduleSelector.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            moduleSelector.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),
*/
            // TabBar constraints
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: max(bottomPadding + 52, 72)),

            /*
            offlineBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offlineBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offlineBanner.topAnchor.constraint(equalTo: view.topAnchor),
            offlineBanner.heightAnchor.constraint(equalToConstant: isOffline ? topPadding + 30 : 0),

            offlineTitle.centerXAnchor.constraint(equalTo: offlineBanner.centerXAnchor),
            offlineTitle.bottomAnchor.constraint(equalTo: offlineBanner.bottomAnchor, constant: -12),
            
            // TopBar constraints
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: offlineBanner.bottomAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 64 + (isOffline ? 0 : topPadding))
             */
        ])

    }

    deinit {
        monitor.cancel()
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

     func didSelectTab(_ tab: Int) {
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

extension AppViewController: UIScrollViewDelegate, UICollectionViewDelegate {
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y - 40

        // topBar.blurView.alpha = -offsetY / 60
    }

     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scenes.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        guard let discoverView = tabs[1] as? DiscoverView else {
            return
        }

        guard let data = discoverView.dataSource?.itemIdentifier(for: indexPath) else {
            return
        }

        /*
        let tempVC = InfoViewRefactor(url: data.url)

        navController.navigationBar.isHidden = true
        navController.pushViewController(tempVC, animated: true)
         */
    }

    // Fade in new cells
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.2) {
            cell.alpha = 1
        }
    }

    // Fade out removed cells
     func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2) {
            cell.alpha = 0
        }
    }
}

/*
extension AppViewController: AppViewTopBarDelegate {
     func didTapButton() {
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
     func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
*/
