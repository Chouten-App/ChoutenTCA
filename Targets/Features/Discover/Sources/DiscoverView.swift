//
//  DiscoverView.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 27.01.24.
//

import Architecture
import Combine
import ComposableArchitecture
import Info
import RelayClient
import SharedModels
import UIKit
import ViewComponents

public class DiscoverView: UIViewController {
    var store: Store<DiscoverFeature.State, DiscoverFeature.Action>

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height

    public let scrollView: UIScrollView = {
        let scrollView                          = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical         = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let view        = UIStackView()
        view.axis       = .vertical
        view.spacing    = 20  // Adjust the spacing between cards
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let scrollViewCarousel: UIScrollView = {
        let scrollView                              = UIScrollView()
        scrollView.isPagingEnabled                  = true
        scrollView.showsHorizontalScrollIndicator   = false
        scrollView.clipsToBounds                    = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let carousel: UIStackView = {
        let view        = UIStackView()
        view.axis       = .horizontal
        view.spacing    = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let loadingView = DiscoverLoadingView()

    var relayObservation: AnyCancellable?

    public init() {
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

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        view.addSubview(loadingView.view)

        NSLayoutConstraint.activate([
            loadingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        observe { [weak self] in
            guard let self else { return }

            if !self.store.discoverSections.isEmpty {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.loadingView.view.alpha = 0
                    }, completion: { _ in
                        self.loadingView.view.removeFromSuperview()

                        self.view.addSubview(self.scrollView)
                        self.scrollView.addSubview(self.contentView)

                        // Adding multiple cards to the stack view
                        self.contentView.addArrangedSubview(self.scrollViewCarousel)
                        self.scrollViewCarousel.addSubview(self.carousel)

                        self.scrollView.alpha = 0
                        self.contentView.alpha = 0
                        self.scrollViewCarousel.alpha = 0
                        self.carousel.alpha = 0

                        NSLayoutConstraint.activate([
                            // ScrollView constraints
                            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
                            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -120),

                            // ContentView constraints
                            self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
                            self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
                            self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 40),
                            self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                            self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),

                            // ScrollViewCarousel constraints
                            self.scrollViewCarousel.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, multiplier: 0.85),
                            self.scrollViewCarousel.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),
                            // self.scrollViewCarousel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                            self.scrollViewCarousel.heightAnchor.constraint(equalToConstant: 480),

                            // Carousel constraints
                            self.carousel.leadingAnchor.constraint(equalTo: self.scrollViewCarousel.contentLayoutGuide.leadingAnchor),
                            self.carousel.trailingAnchor.constraint(equalTo: self.scrollViewCarousel.contentLayoutGuide.trailingAnchor),
                            self.carousel.topAnchor.constraint(equalTo: self.scrollViewCarousel.contentLayoutGuide.topAnchor),
                            self.carousel.bottomAnchor.constraint(equalTo: self.scrollViewCarousel.contentLayoutGuide.bottomAnchor)
                        ])

                        UIView.animate(withDuration: 0.3) {
                            self.scrollView.alpha = 1
                            self.contentView.alpha = 1
                            self.scrollViewCarousel.alpha = 1
                            self.carousel.alpha = 1
                        }

                        let firstList = self.store.discoverSections.first
                        if let firstList {
                            for i in 0..<firstList.list.count {
                                DispatchQueue.main.async {
                                    let data = firstList.list[i]
                                    let card = CarouselCard(data: data)

                                    card.delegate = self

                                    self.carousel.addArrangedSubview(card)
                                    card.widthAnchor.constraint(equalTo: self.scrollViewCarousel.frameLayoutGuide.widthAnchor).isActive = true
                                }
                            }
                        }

                        for index in 1..<self.store.discoverSections.count {
                            DispatchQueue.main.async {
                                let sectionList = SectionList(section: self.store.discoverSections[index])

                                sectionList.delegate = self

                                self.contentView.addArrangedSubview(sectionList)

                                NSLayoutConstraint.activate([
                                    sectionList.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
                                    sectionList.heightAnchor.constraint(equalToConstant: 220)
                                ])
                            }
                        }
                    })
                }
            } else {
                DispatchQueue.main.async {
                    self.carousel.arrangedSubviews.forEach { $0.removeFromSuperview() }
                    self.contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                    self.view.addSubview(self.loadingView.view)
                }
            }
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
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

extension DiscoverView: CarouselCardDelegate {
    public func carouselCardDidTap(_ data: DiscoverData) {
        guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scenes.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        guard let tappedCard = carousel.arrangedSubviews.first(where: { ($0 as? CarouselCard)?.data == data }) as? CarouselCard else {
            print("not found")
            return
        }

        let tempVC = InfoViewRefactor(url: data.url)

        navController.navigationBar.isHidden = true
        navController.pushViewController(tempVC, animated: true)
    }
}


extension DiscoverView: SectionListDelegate {
    public func didTap(_ data: DiscoverData) {
        print(data)
        // Handle the onTap action here

        let scenes = UIApplication.shared.connectedScenes

        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        let tempVC = InfoViewRefactor(url: data.url)
        navController.navigationBar.isHidden = true
        navController.pushViewController(tempVC, animated: true)
    }
}
