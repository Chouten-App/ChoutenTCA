//
//  DiscoverView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 27.01.24.
//

import Combine
import ComposableArchitecture
import UIKit

class DiscoverView: UIViewController {
    var store: Store<DiscoverFeature.State, DiscoverFeature.Action>

    var collectionView: UICollectionView!

    let loadingView = DiscoverLoadingView()

    var dataSource: UICollectionViewDiffableDataSource<DiscoverSection, DiscoverData>?

    init() {
        store = .init(
            initialState: .init(),
            reducer: { DiscoverFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear))
        // NotificationCenter.default.addObserver(self, selector: #selector(handleChangedModule), name: .changedModule, object: nil)
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
        collectionView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        view.addSubview(loadingView.view)
        addChild(loadingView)

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

            if !store.discoverSections.isEmpty {
                loadingView.view.removeFromSuperview()
                loadingView.removeFromParent()
                reloadData()
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140),

            loadingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
            if self.store.discoverSections.isEmpty {
                return self.configure(ListCell.self, with: data, for: indexPath)
            }

            switch self.store.discoverSections[indexPath.section].type {
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
        var snapshot = NSDiffableDataSourceSnapshot<DiscoverSection, DiscoverData>()
        snapshot.appendSections(self.store.discoverSections)

        for section in self.store.discoverSections {
            snapshot.appendItems(section.list, toSection: section)
        }

        if snapshot.numberOfItems > 0 {
            dataSource?.apply(snapshot)
        }
    }

    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let section = self.store.discoverSections[sectionIndex]

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
