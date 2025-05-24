//
//  DiscoverView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 27.01.24.
//

import Core
import Combine
import ComposableArchitecture
import UIKit

class DiscoverView: UIViewController, UICollectionViewDelegate {
    var store: Store<DiscoverFeature.State, DiscoverFeature.Action>

    var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl!

    let loadingView = DiscoverLoadingView()
    let noRepoInstalledView = TitleCard("No Module Installed.", description: "Please install and select a module using publicly available repos.")

    var dataSource: UICollectionViewDiffableDataSource<DiscoverSection, DiscoverData>?
    
    // Computed property to get combined sections with continue watching
    private var combinedSections: [DiscoverSection] {
        var sections = store.discoverSections
        
        // Only add continue watching if we have data and discover sections
        if !store.continueWatchingData.isEmpty && !sections.isEmpty {
            let continueWatchingSection = DiscoverSection(
                title: "Continue Watching",
                type: 1, // List type
                list: store.continueWatchingData
            )
            
            // Insert between first and last section
            if sections.count == 1 {
                // If only one section, append continue watching
                sections.append(continueWatchingSection)
            } else {
                // Insert at index 1 (between first and others)
                let insertIndex = min(1, sections.count)
                sections.insert(continueWatchingSection, at: insertIndex)
            }
        }
        
        return sections
    }

    init() {
        store = .init(
            initialState: .init(),
            reducer: { DiscoverFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear))
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangedModule), name: .changedModule, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        
        // setup collectionview
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 80, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        // Setup refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        view.addSubview(noRepoInstalledView)
        view.addSubview(loadingView.view)
        addChild(loadingView)
        loadingView.didMove(toParent: self)
        loadingView.view.isHidden = true
        
        view.addSubview(collectionView)
        
        // register cells
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseIdentifier)
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseIdentifier
        )
        
        createDataSource()
        
        observe { [weak self] in
            guard let self else { return }
            
            // Handle refresh control state
            if store.isRefreshing {
                if !refreshControl.isRefreshing {
                    refreshControl.beginRefreshing()
                }
            } else {
                if refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
            
            if !store.discoverSections.isEmpty {
                print("Found Data")
                noRepoInstalledView.isHidden = true
                loadingView.view.isHidden = true
                collectionView.isHidden = false
                reloadData()
            }
            
            else if store.state.discoverSections.isEmpty {
                reloadData()
                noRepoInstalledView.isHidden = true
                loadingView.view.isHidden = false
                collectionView.isHidden = true
            }
        }
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        let topPadding = window?.safeAreaInsets.top ?? 0.0
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 40),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // No Repo Selected
            noRepoInstalledView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noRepoInstalledView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noRepoInstalledView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 80)
        ])
        
        if loadingView.parent != nil {
            NSLayoutConstraint.activate([
                loadingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.view.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        collectionView.delegate = self
    }

    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with data: DiscoverData, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Failed to get cell of type \(cellType).")
        }

        cell.configure(with: data)
        return cell
    }

    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DiscoverSection, DiscoverData>(collectionView: collectionView) { collectionView, indexPath, data in
            if self.combinedSections.isEmpty {
                return self.configure(ListCell.self, with: data, for: indexPath)
            }

            switch self.combinedSections[indexPath.section].type {
            case 0:
                return self.configure(CarouselCell.self, with: data, for: indexPath)
            default:
                return self.configure(ListCell.self, with: data, for: indexPath)
            }
        }

        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeader.reuseIdentifier,
                for: indexPath
            ) as? SectionHeader else {
                return nil
            }

            guard let firstData = self?.dataSource?.itemIdentifier(for: indexPath) else {
                return nil
            }

            guard let section = self?.dataSource?.snapshot().sectionIdentifier(containingItem: firstData) else {
                return nil
            }

            sectionHeader.label.text = section.title
            return sectionHeader
        }
    }

    func reloadData() {
        let sections = combinedSections
        if sections.isEmpty { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<DiscoverSection, DiscoverData>()
        snapshot.appendSections(sections)

        for section in sections {
            snapshot.appendItems(section.list, toSection: section)
        }

        if snapshot.numberOfItems > 0 {
            dataSource?.apply(snapshot)
        }
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sections = self.combinedSections
            guard sectionIndex < sections.count else {
                return self.createListSection(using: DiscoverSection(title: "", type: 1, list: []))
            }
            
            let section = sections[sectionIndex]

            switch section.type {
            case 0:
                return self.createCarouselSection(using: section)
            default:
                return self.createListSection(using: section)
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration

        return layout
    }

    func createCarouselSection(using section: DiscoverSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(420))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.interGroupSpacing = 20
        return layoutSection
    }

    func createListSection(using section: DiscoverSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .estimated(180))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.interGroupSpacing = 12
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]

        return layoutSection
    }

    override  func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        self.view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
    }

    @objc func handleChangedModule() {
        store.send(.view(.onAppear))
    }
    
    @objc private func refreshData() {
        store.send(.view(.refresh))
    }

    private func updateTopBarBlur(offsetY: CGFloat) {
        //Parent View Access
        if let appViewController = self.parent as? AppViewController {
            appViewController.topBar.blurView.alpha = -offsetY / 60
        }
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: Extensions

extension DiscoverView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y - 40
        //Delegate Not working, needs to be fixed if parent access is bad
        //appViewDelegate?.setTopBlur(offset: -offsetY)
        updateTopBarBlur(offsetY: offsetY)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = scenes.windows.first,
             let navController = window.rootViewController as? UINavigationController else {
           return
       }

       guard let data = dataSource?.itemIdentifier(for: indexPath) else {
           return
       }
       
       // Check if this is a continue watching item
       let sections = combinedSections
       if indexPath.section < sections.count && sections[indexPath.section].title == "Continue Watching" {
           handleContinueWatchingTap(for: data)
       } else {
           // Handle normal discover navigation
           let tempVC = InfoViewRefactor(url: data.url)
           navController.navigationBar.isHidden = true
           navController.pushViewController(tempVC, animated: true)
       }
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

   private func handleContinueWatchingTap(for data: DiscoverData) {
       // Get the full continue watching data from the database
       Task {
           do {
               let continueWatchingData = await self.getContinueWatchingData(for: data.url)
               
               if let (infoData, mediaData, savedProgress, duration) = continueWatchingData {
                   DispatchQueue.main.async {
                       self.navigateToPlayer(infoData: infoData, mediaData: mediaData, savedProgress: savedProgress, duration: duration)
                   }
               } else {
                   print("Failed to get continue watching data for \(data.titles.primary)")
                   // Fallback to normal info navigation
                   DispatchQueue.main.async {
                       self.navigateToInfo(url: data.url)
                   }
               }
           }
       }
   }
   
   private func getContinueWatchingData(for url: String) async -> (InfoData, MediaItem, Double, Double)? {
       // Access the database client through the dependency system
       return await withDependencies(from: self.store) {
           @Dependency(\.databaseClient) var databaseClient
           return await databaseClient.fetchContinueWatchingData(url)
       }
   }
   
   private func navigateToPlayer(infoData: InfoData, mediaData: MediaItem, savedProgress: Double, duration: Double) {
       guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = scenes.windows.first,
             let navController = window.rootViewController as? UINavigationController else {
           return
       }
       
       // Create PlayerVC with the media data, info, and saved progress
       let playerVC = PlayerVC(data: mediaData, info: infoData, index: 0, savedProgress: savedProgress)
       playerVC.modalPresentationStyle = .fullScreen
       
       let transition = CATransition()
       transition.duration = 0.3
       transition.type = .fade
       navController.view.layer.add(transition, forKey: nil)
       navController.navigationBar.isHidden = true
       navController.pushViewController(playerVC, animated: false)
   }
   
   private func navigateToInfo(url: String) {
       guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
             let window = scenes.windows.first,
             let navController = window.rootViewController as? UINavigationController else {
           return
       }
       
       let infoVC = InfoViewRefactor(url: url)
       navController.navigationBar.isHidden = true
       navController.pushViewController(infoVC, animated: true)
   }
}
