//
//  SuccessInfoVC.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import Architecture
import SharedModels
import UIKit
import ViewComponents

class LoadingInfoVC: UIViewController {
    let topBar = InfoTopBar(title: InfoData.sample.titles.primary)

    let headerDisplay: LoadingInfoHeaderDisplay
    let extraInfoDisplay: LoadingExtraInfoDisplay
    let seasonDisplay: LoadingSeasonDisplay
    let mediaListDisplay: LoadingMediaListDisplay

    lazy var scrollView: UIScrollView = createScrollView()
    lazy var contentView: UIStackView = createContentView()

    var offsetY: Double = 0.0

    // MARK: Lifecycle

    init() {
        self.headerDisplay = LoadingInfoHeaderDisplay(offsetY: offsetY)
        self.extraInfoDisplay = LoadingExtraInfoDisplay()
        self.seasonDisplay = LoadingSeasonDisplay()
        self.mediaListDisplay = LoadingMediaListDisplay()
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: View Lifecycle

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        scrollView.delegate = self

        scrollView.addSubview(contentView)

        contentView.addArrangedSubview(headerDisplay)
        contentView.addArrangedSubview(extraInfoDisplay)
        contentView.addArrangedSubview(seasonDisplay)
        contentView.addArrangedSubview(mediaListDisplay)

        view.addSubview(scrollView)
        view.addSubview(topBar)

        setupConstraints()
    }

    // MARK: Layout
    private func setupConstraints() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        let topPadding = window?.safeAreaInsets.top ?? 0.0

        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.heightAnchor.constraint(equalToConstant: topPadding + 40),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            seasonDisplay.heightAnchor.constraint(equalToConstant: 32 + 6 + 14)
        ])
    }

    // MARK: Helpers
    private func createScrollView() -> UIScrollView {
        let scrollView                              = UIScrollView()
        scrollView.alwaysBounceVertical             = true
        scrollView.showsVerticalScrollIndicator     = false
        scrollView.contentInsetAdjustmentBehavior   = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private func createContentView() -> UIStackView {
        let stack       = UIStackView()
        stack.axis      = .vertical
        stack.spacing   = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}

// MARK: UIScrollViewDelegate
extension LoadingInfoVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y

        topBar.blurView.alpha = -offsetY / 120

        headerDisplay.view.clipsToBounds = offsetY <= 0

        let heightOffset = max((offsetY) - 40, -40)

        headerDisplay.bannerHeightConstraint.constant = heightOffset
    }
}
