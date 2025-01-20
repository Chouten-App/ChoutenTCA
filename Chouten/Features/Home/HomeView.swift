//
//  HomeView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 05.03.24.
//

import Core
import Combine
import ComposableArchitecture
import UIKit

struct FooterKind {
    static let addCollectionFooter = "AddCollectionFooter"
    static let emptySectionFooter = "EmptySectionFooter"
}

class HomeView: UIViewController {
    var store: Store<HomeFeature.State, HomeFeature.Action>
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeData>?
    private var refreshControl = UIRefreshControl()
    
    var isSelectionMode: Bool = false
    var selectedItems: Set<IndexPath> = []
    
    let soonLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon!"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let deleteButton = CircleButton(icon: "trash")
    
    init() {
        store = .init(
            initialState: .init(),
            reducer: { HomeFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear))
        reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        
        navigationController?.navigationBar.isHidden = true
        
        configure()
        createDataSource()

        observe { [weak self] in
            guard let self else { return }

            if !self.store.collections.isEmpty {
                self.reloadData()
            }
        }
        
        setupConstraints()
    }

    private func configure() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        collectionView.contentInset = UIEdgeInsets(top: topPadding + 30, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true // Enable multi-selection
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        deleteButton.addTarget(self, action: #selector(deleteSelectedItems), for: .touchUpInside)

        view.addSubview(collectionView)
        view.addSubview(deleteButton)

        collectionView.register(ContinueWatchingCard.self, forCellWithReuseIdentifier: ContinueWatchingCard.reuseIdentifier)
        collectionView.register(CarouselCellHome.self, forCellWithReuseIdentifier: CarouselCellHome.reuseIdentifier)
        collectionView.register(ListCellHome.self, forCellWithReuseIdentifier: ListCellHome.reuseIdentifier)
        collectionView.register(
            SectionHeaderHome.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderHome.reuseIdentifier
        )
        collectionView.register(
            EmptySectionFooter.self,
            forSupplementaryViewOfKind: FooterKind.emptySectionFooter,
            withReuseIdentifier: EmptySectionFooter.reuseIdentifier
        )
        collectionView.register(
            AddCollectionFooter.self,
            forSupplementaryViewOfKind: FooterKind.addCollectionFooter,
            withReuseIdentifier: AddCollectionFooter.reuseIdentifier
        )
        
        collectionView.delegate = self
    }

    
    @objc private func handleRefresh() {
        store.send(.view(.onAppear))
        reloadData()
        refreshControl.endRefreshing()
    }
    
    func configure<T: SelfConfiguringCellHome>(_ cellType: T.Type, with data: HomeData, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Failed to get cell of type \(cellType).")
        }

        cell.configure(with: data)
        return cell
    }

    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140),
            
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 60)
        ])
        
        deleteButton.alpha = 0
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeData>(collectionView: collectionView) { collectionView, indexPath, data in
            print("*** datsource")
            print(collectionView)
            print("")
            print(indexPath)
            print(data)
            
            switch self.store.collections[indexPath.section].type {
            case 3:
                return self.configure(ContinueWatchingCard.self, with: data, for: indexPath)
            case 0:
                return self.configure(CarouselCellHome.self, with: data, for: indexPath)
            default:
                return self.configure(ListCellHome.self, with: data, for: indexPath)
            }
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return UICollectionReusableView() }
            
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderHome.reuseIdentifier, for: indexPath) as! SectionHeaderHome

                guard let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section] else {
                    return UICollectionReusableView()
                }
                
                headerView.configure(with: section.title, id: section.id)
                headerView.delegate = self
                
                headerView.onDelete = {
                    self.handleDeleteConfirmation(for: section)
                }
                
                return headerView
            case FooterKind.emptySectionFooter:
                let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
                
                // If the section's list is empty, show the empty footer first
                let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: EmptySectionFooter.reuseIdentifier,
                    for: indexPath) as! EmptySectionFooter
                return footerView
            case FooterKind.addCollectionFooter:
                let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
                
                // Regular footer for non-empty section
                let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: AddCollectionFooter.reuseIdentifier,
                    for: indexPath) as! AddCollectionFooter
                footerView.delegate = self
                footerView.isHidden = !(indexPath.section == self.store.collections.count - 2)
                return footerView
            default:
                return nil
            }
        }
    }

    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeData>()
        
        if !self.store.collections.isEmpty {
            snapshot.appendSections(self.store.collections)
            for section in self.store.collections {
                snapshot.appendItems(section.list, toSection: section)
            }
        }

        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            
            let section = self.store.collections[sectionIndex]

            switch section.type {
            case 3:
                let sectionLayout = self.createContinueWatchingCarousel(using: section)
                return sectionLayout
            default:
                let isLast = sectionIndex == self.store.collections.count - 2
                let sectionLayout = self.createListSection(using: section, isLast: isLast)
                return sectionLayout
            }
        }

        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        layout.configuration = configuration

        return layout
    }
    
    func createContinueWatchingCarousel(using section: HomeSection) -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .fractionalHeight(1.0)
            )
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(280),
                heightDimension: .absolute(190)
            )
        let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [layoutItem])
            layoutGroup.interItemSpacing = .fixed(12)

            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

            return layoutSection
        }

    func createListSection(using section: HomeSection, isLast: Bool = false) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .estimated(200))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        layoutSection.interGroupSpacing = 12
        layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        // Header
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        layoutSection.boundarySupplementaryItems = [layoutSectionHeader]
        
        var addFooterHeight: Double = 0.0
        
        if section.list.isEmpty {
            let emptyCollectionFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(70))
            let emptyCollectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: emptyCollectionFooterSize,
                elementKind: FooterKind.emptySectionFooter,
                alignment: .bottom
            )
            layoutSection.boundarySupplementaryItems.append(emptyCollectionFooter)
            
            addFooterHeight += 70.0
        }

        let layoutSectionFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(isLast ? addFooterHeight + 50 : 0)) // Adjust height for the last footer
        let layoutSectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: layoutSectionFooterSize,
            elementKind: FooterKind.addCollectionFooter,
            alignment: .bottom
        )
        layoutSection.boundarySupplementaryItems.append(layoutSectionFooter)

        return layoutSection
    }
    
    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "New Collection", message: "Enter a name for the new collection", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Collection Name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self, let textField = alertController.textFields?.first, let name = textField.text, !name.isEmpty else {
                return
            }
            self.store.send(.view(.createCollection(name)))
            reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func deleteSelectedItems() {
        isSelectionMode.toggle()
        
        let selectedData = selectedItems.map { indexPath in
            store.collections[indexPath.section].list[indexPath.item]
        }
        
        // Remove selected items from data source
        for indexPath in selectedItems {
            store.send(.view(.deleteItem(store.collections[indexPath.section].id, store.collections[indexPath.section].list[indexPath.item])))
        }
        
        // Update collection view
        
        // Clear selection
        selectedItems.removeAll()
        
        updateUIForSelection()
        
        collectionView.allowsMultipleSelection = false
        selectedItems.removeAll()
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.deleteButton.transform = .identity
            self.deleteButton.alpha = 0
        }) { _ in
            self.collectionView.visibleCells.forEach { cell in
                if let listCell = cell as? ListCellHome,
                   let _ = self.collectionView.indexPath(for: cell) {
                    listCell.setSelected(false)
                }
            }
            
            self.collectionView.indexPathsForSelectedItems?.forEach { indexPath in
                self.collectionView.deselectItem(at: indexPath, animated: false)
            }
            self.handleRefresh()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        soonLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    }
    
    func updateUIForSelection() {
        deleteButton.isHidden = !isSelectionMode || selectedItems.isEmpty
        
        collectionView.visibleCells.forEach { cell in
            if let listCell = cell as? ListCellHome,
               let indexPath = collectionView.indexPath(for: cell) {
                listCell.setSelected(selectedItems.contains(indexPath))
            }
        }
    }
    
    private func handleDeleteConfirmation(for section: HomeSection) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this collection?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.store.send(.view(.deleteCollection(section.id)))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension HomeView: SectionHeaderHomeDelegate {
    func didUpdateCollectionName(of collectionId: String, to name: String) {
        store.send(.view(.updateCollectionName(collectionId, name)))
    }
}

extension HomeView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            selectedItems.insert(indexPath)
            updateUIForSelection()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            selectedItems.remove(indexPath)
            updateUIForSelection()
        }
    }
}

extension HomeView: AddCollectionFooterDelegate {
    func createCollection() {
        store.send(.view(.createCollection("Collection")))
    }
}
