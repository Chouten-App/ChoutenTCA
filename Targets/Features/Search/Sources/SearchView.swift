//
//  SearchView.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import ComposableArchitecture
import Info
import RelayClient
import SharedModels
import UIKit
import ViewComponents

public class SearchView: UIViewController {
    var store: Store<SearchFeature.State, SearchFeature.Action>

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    private var lastSearchTxt = ""

    public let scrollView: UIScrollView = {
        let scrollView                          = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical         = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let view            = UIStackView()
        view.axis           = .vertical
        view.alignment      = .center
        view.distribution   = .equalCentering
        view.spacing        = 20  // Adjust the spacing between cards
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var collectionView: UICollectionView!

    public var dataSource: UICollectionViewDiffableDataSource<Int, SearchData>?

    let emptyQueryCard = EmoteCard(
        ".-.",
        description: "You haven't searched for anything yet.\nMaybe try adding a query to search for something."
    )

    let header = SearchHeader()

    public init() {
        store = .init(
            initialState: .init(),
            reducer: { SearchFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        store.send(.view(.onAppear))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        // setup collectionview
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 180) // Set item size
        layout.minimumInteritemSpacing = 20 // Set spacing between items
        layout.minimumLineSpacing = 20 // Set spacing between lines

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = false
        collectionView.delegate = self
        collectionView.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        collectionView.contentInset = UIEdgeInsets(top: 68, left: 20, bottom: 20, right: 20)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

        header.translatesAutoresizingMaskIntoConstraints = false

        header.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        header.textField.addTarget(self, action: #selector(textFieldShouldReturn(_:)), for: .editingDidEndOnExit)

        view.addSubview(collectionView)
        view.addSubview(header)

        // register cells
        collectionView.register(SearchCell.self, forCellWithReuseIdentifier: SearchCell.reuseIdentifier)

        createDataSource()

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        observe { [weak self] in
            guard let self else { return }

            switch store.status {
            case .idle:
                break
//                DispatchQueue.main.async {
//                    self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//                    self.contentView.addArrangedSubview(self.emptyQueryCard)
//                }
            case .loading:
                break
//                DispatchQueue.main.async {
//                    self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//
//                    let activityIndicator = UIActivityIndicatorView(style: .medium)
//                    activityIndicator.tintColor = ThemeManager.shared.getColor(for: .fg)
//                    activityIndicator.startAnimating()
//                    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//
//                    // Add the activity indicator to the content view
//                    self.contentView.addArrangedSubview(activityIndicator)
//
//                    // Optionally, add constraints to center it within the contentView if needed
//                    NSLayoutConstraint.activate([
//                        activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
//                        activityIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
//                    ])
//                }
            case .success:
                if let result = store.result {
                    if result.results.isEmpty {
                        reloadData()
//                        DispatchQueue.main.async {
//                            self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//                            let card = EmoteCard(
//                                ".-.",
//                                description: "No results found with that query."
//                            )
//                            self.contentView.addArrangedSubview(card)
//                        }
                    } else {
                        reloadData()
//                        DispatchQueue.main.async {
//                            print(result)
//                            let collectionView = SearchCollectionView(result: result, layout: UICollectionViewFlowLayout())
//                            collectionView.reloadData()
//                            self.scrollView.removeFromSuperview()
//                            self.view.addSubview(collectionView)
//                            collectionView.delegate = self
//                            collectionView.translatesAutoresizingMaskIntoConstraints = false
//
//                            NSLayoutConstraint.activate([
//                                collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
//                                collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
//                                collectionView.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: 12),
//                                collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//                            ])
//                        }
                    }
                }
            case .error:
                break
            }
        }
    }

    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, SearchData>(collectionView: collectionView) { collectionView, indexPath, data in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchCell.reuseIdentifier,
                for: indexPath
            ) as? SearchCell else {
                return nil
            }

            cell.configure(with: data)

            return cell
        }
    }

    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, SearchData>()
        snapshot.appendSections([0])
        if let searchResults = store.result {
            snapshot.appendItems(searchResults.results, toSection: 0)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let queryText = self.header.textField.text {
            UIView.animate(withDuration: 0.2) {
                self.header.clearButton.alpha = queryText.isEmpty || (self.header.textField.text == nil) ? 0.0 : 1.0
            }
        }
        if lastSearchTxt.isEmpty {
            lastSearchTxt = textField.text ?? ""
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(debounceCall), object: lastSearchTxt)
        lastSearchTxt = textField.text ?? ""
        self.perform(#selector(debounceCall), with: textField.text, afterDelay: 0.7)
    }

    @objc func debounceCall(sender: String) {
        if !sender.isEmpty {
            store.send(.view(.setQuery(sender)))
        }
    }

    @objc func clearQuery() {
        header.textField.text = ""
        UIView.animate(withDuration: 0.2) {
            self.header.clearButton.alpha = 0.0
        }
        store.send(.view(.clearQuery))
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !header.textField.frame.contains(location) && !header.clearButton.frame.contains(location) {
            view.endEditing(true)
        }
    }
}

// MARK: UIScrollViewDelegate
extension SearchView: UIScrollViewDelegate, UICollectionViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y - 120

        header.blurView.alpha = -offsetY / 60

        guard store.result != nil,
        store.loading == false else { return }

        // check if reached the bottom
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) {[weak self] t in
            let contentOffsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height

            if contentOffsetY >= (contentHeight - scrollViewHeight) {
                self?.store.send(.view(.paginateSearch))
            }
            t.invalidate()
        }
    }
}
