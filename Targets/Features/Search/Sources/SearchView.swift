//
//  SearchView.swift
//  Search
//
//  Created by Inumaki on 15.05.24.
//

import Architecture
import Combine
import ComposableArchitecture
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

    let emptyQueryCard = EmoteCard(
        ".-.",
        description: "You haven't searched for anything yet.\nMaybe try adding a query to search for something."
    )

    let header = SearchHeader()

    var relayObservation: AnyCancellable?

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

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.delegate = self

        contentView.addArrangedSubview(emptyQueryCard)

        header.translatesAutoresizingMaskIntoConstraints = false
        header.layer.zPosition = 100
        view.addSubview(header)

        header.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        header.clearButton.addTarget(self, action: #selector(clearQuery), for: .touchDown)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -60),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        view.addGestureRecognizer(tapGesture)

        observe { [weak self] in
            guard let self else { return }

            switch store.status {
            case .idle:
                DispatchQueue.main.async {
                    self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                    self.contentView.addArrangedSubview(self.emptyQueryCard)
                }
            case .loading:
                DispatchQueue.main.async {
                    self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }

                    let activityIndicator = UIActivityIndicatorView(style: .medium)
                    activityIndicator.tintColor = ThemeManager.shared.getColor(for: .fg)
                    activityIndicator.startAnimating()
                    activityIndicator.translatesAutoresizingMaskIntoConstraints = false

                    // Add the activity indicator to the content view
                    self.contentView.addArrangedSubview(activityIndicator)

                    // Optionally, add constraints to center it within the contentView if needed
                    NSLayoutConstraint.activate([
                        activityIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
                        activityIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
                    ])
                }
            case .success:
                if let result = store.result {
                    if result.results.isEmpty {
                        DispatchQueue.main.async {
                            self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                            let card = EmoteCard(
                                ".-.",
                                description: "No results found with that query."
                            )
                            self.contentView.addArrangedSubview(card)
                        }
                    } else {
                        DispatchQueue.main.async {
                            print(result)
                            let collectionView = SearchCollectionView(result: result, layout: UICollectionViewFlowLayout())
                            collectionView.reloadData()
                            self.scrollView.removeFromSuperview()
                            self.view.addSubview(collectionView)
                            collectionView.delegate = self
                            collectionView.translatesAutoresizingMaskIntoConstraints = false

                            NSLayoutConstraint.activate([
                                collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                                collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                                collectionView.topAnchor.constraint(equalTo: self.header.bottomAnchor, constant: 12),
                                collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
                            ])
                        }
                    }
                }
            case .error:
                break
            }
        }
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
        print(sender)
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
        let offsetY = -scrollView.contentOffset.y

        header.blurView.alpha = -offsetY / 60

        guard store.result != nil,
        store.loading == false  else { return }

        // check if reached the bottom
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) {[weak self] t in
            let contentOffsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let scrollViewHeight = scrollView.frame.size.height

            if contentOffsetY >= (contentHeight - scrollViewHeight) {
                print("bottom")
                self?.store.send(.view(.paginateSearch))
            }
            t.invalidate()
        }
    }
}
