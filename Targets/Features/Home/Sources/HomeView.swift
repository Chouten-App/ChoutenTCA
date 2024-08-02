//
//  HomeView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 05.03.24.
//

import Architecture
import Combine
import ComposableArchitecture
import UIKit
import SharedModels
import ViewComponents

public class HomeView: UIViewController {
    var store: Store<HomeFeature.State, HomeFeature.Action>
    
    public var collectionView: UICollectionView!
    public var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeData>?
    
    let soonLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon!"
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let addButton = CircleButton(icon: "plus");
    
    public init() {
        store = .init(
            initialState: .init(),
            reducer: { HomeFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear))
        print(store.collections.count)
        reloadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        configure()
        createDataSource()

        observe { [weak self] in
            guard let self else { return }

            if !store.collections.isEmpty {
                reloadData()
            }
        }
        
        setupConstraints()
    }

    private func configure() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        addButton.isUserInteractionEnabled = true
        addButton.onTap = {
            self.addButtonTapped()
        }

        view.addSubview(collectionView)
        view.addSubview(addButton)

        // register cells
        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseIdentifier)
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: ListCell.reuseIdentifier)
        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeader.reuseIdentifier
        )
    }
    
    func configure<T: SelfConfiguringCell>(_ cellType: T.Type, with data: HomeData, for indexPath: IndexPath) -> T {
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
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 40),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: topPadding + 60),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeData>(collectionView: collectionView) { collectionView, indexPath, data in
            switch self.store.collections[indexPath.section].type {
            case 0:
                return self.configure(CarouselCell.self, with: data, for: indexPath)
            default:
                return self.configure(ListCell.self, with: data, for: indexPath)
            }
        }
        
        dataSource?.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self = self else { return nil }

            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseIdentifier, for: indexPath) as! SectionHeader

                guard let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section] else {
                    return nil
                }
                
                headerView.label.text = section.title
                return headerView
            }

            return nil
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

    func createCarouselSection(using section: HomeSection) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(420))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [layoutItem])

        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.interGroupSpacing = 20
        return layoutSection
    }

    func createListSection(using section: HomeSection) -> NSCollectionLayoutSection {
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
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }

    func updateAppearance() {
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        soonLabel.textColor = ThemeManager.shared.getColor(for: .fg)
    }
}
