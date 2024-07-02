//
//  SuccessInfoVC.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import Architecture
import SharedModels
import UIKit
import Video
import ViewComponents

public class SuccessInfoVC: UIViewController {

    var infoData: InfoData

    var doneLoading = false

    let topBar = InfoTopBar(title: InfoData.freeToUseData.titles.primary)

    let headerDisplay: InfoHeaderDisplay
    let extraInfoDisplay: ExtraInfoDisplay
    let seasonDisplay: SeasonDisplay
    let mediaListDisplay: MediaListDisplay
    let loadingSeasonDisplay: LoadingSeasonDisplay
    let loadingMediaListDisplay: LoadingMediaListDisplay
    let seasonSelector: SeasonSelectorView

    lazy var scrollView: UIScrollView = createScrollView()
    lazy var contentView: UIStackView = createContentView()

    var offsetY: Double = 0.0

    // MARK: Lifecycle

    public init(infoData: InfoData) {
        self.infoData = infoData
        self.headerDisplay = InfoHeaderDisplay(infoData: infoData, offsetY: offsetY)
        self.extraInfoDisplay = ExtraInfoDisplay(infoData: infoData)
        self.seasonDisplay = SeasonDisplay(infoData: infoData)
        self.mediaListDisplay = MediaListDisplay(infoData: infoData)
        self.loadingSeasonDisplay = LoadingSeasonDisplay()
        self.loadingMediaListDisplay = LoadingMediaListDisplay()
        self.seasonSelector = SeasonSelectorView(infoData.seasons)
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: View Lifecycle

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateData() {
        topBar.titleLabel.text = infoData.titles.primary

        headerDisplay.infoData = infoData
        headerDisplay.updateData()

        extraInfoDisplay.infoData = infoData
        extraInfoDisplay.updateData()

        if !infoData.mediaList.isEmpty {
            self.loadingSeasonDisplay.alpha = 1.0
            self.loadingMediaListDisplay.alpha = 1.0
            UIView.animate(withDuration: 0.2, animations: {
                self.loadingSeasonDisplay.alpha = 0.0
                self.loadingMediaListDisplay.alpha = 0.0
            }, completion: { _ in
                self.loadingSeasonDisplay.removeFromSuperview()
                self.loadingMediaListDisplay.removeFromSuperview()

                self.seasonDisplay.infoData = self.infoData
                self.seasonDisplay.updateData()

                self.mediaListDisplay.infoData = self.infoData
                self.mediaListDisplay.updateData()

                self.seasonDisplay.alpha = 0.0
                self.mediaListDisplay.alpha = 0.0

                self.contentView.addArrangedSubview(self.seasonDisplay)
                self.contentView.addArrangedSubview(self.mediaListDisplay)

                UIView.animate(withDuration: 0.2) {
                    self.seasonDisplay.alpha = 1.0
                    self.mediaListDisplay.alpha = 1.0
                }
            })

        } else {
            if doneLoading {
                UIView.animate(withDuration: 0.2) {
                    self.seasonDisplay.removeFromSuperview()
                    self.mediaListDisplay.removeFromSuperview()
                    self.loadingSeasonDisplay.removeFromSuperview()
                    self.loadingMediaListDisplay.removeFromSuperview()

                    // add error display
                    let titleCard = TitleCard("No Media Found.", description: "This title doesnt seem to have any media yet...")

                    self.contentView.addArrangedSubview(titleCard)

                    self.contentView.layoutIfNeeded()
                }
            } else {
                self.seasonDisplay.alpha = 1.0
                self.mediaListDisplay.alpha = 1.0

                // Animate the alpha values
                UIView.animate(withDuration: 0.2, animations: {
                    // Fade out the existing views
                    self.seasonDisplay.alpha = 0.0
                    self.mediaListDisplay.alpha = 0.0
                }, completion: { _ in
                    // Remove the existing views from superview after fade out animation completes
                    self.seasonDisplay.removeFromSuperview()
                    self.mediaListDisplay.removeFromSuperview()

                    // Add new views with alpha set to 0.0
                    self.loadingSeasonDisplay.alpha = 0.0
                    self.loadingMediaListDisplay.alpha = 0.0
                    self.contentView.addArrangedSubview(self.loadingSeasonDisplay)
                    self.contentView.addArrangedSubview(self.loadingMediaListDisplay)

                    // Fade in the new views
                    UIView.animate(withDuration: 0.2) {
                        self.loadingSeasonDisplay.alpha = 1.0
                        self.loadingMediaListDisplay.alpha = 1.0
                    }
                })
            }
        }

        viewWillLayoutSubviews()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        scrollView.delegate = self

        scrollView.addSubview(contentView)

        contentView.addArrangedSubview(headerDisplay)
        contentView.addArrangedSubview(extraInfoDisplay)
        if !infoData.mediaList.isEmpty {
            contentView.addArrangedSubview(seasonDisplay)
            contentView.addArrangedSubview(mediaListDisplay)
        } else {
            contentView.addArrangedSubview(loadingSeasonDisplay)
            contentView.addArrangedSubview(loadingMediaListDisplay)
        }

        view.addSubview(scrollView)
        view.addSubview(topBar)

        topBar.layer.zPosition = 100

        setupConstraints()

        mediaListDisplay.delegate = self

        // view.addSubview(seasonSelector)
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

            seasonDisplay.heightAnchor.constraint(equalToConstant: 32 + 6 + 18 + 24),
            loadingSeasonDisplay.heightAnchor.constraint(equalToConstant: 32 + 6 + 14),

//            seasonSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            seasonSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            seasonSelector.topAnchor.constraint(equalTo: view.topAnchor),
//            seasonSelector.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
extension SuccessInfoVC: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = -scrollView.contentOffset.y

        topBar.blurView.alpha = -offsetY / 120
        topBar.titleLabel.alpha = -offsetY / 120

        headerDisplay.view.clipsToBounds = offsetY <= 0

        let heightOffset = max((offsetY) - 40, -40)

        headerDisplay.bannerHeightConstraint.constant = heightOffset
    }
}

extension SuccessInfoVC: MediaListDelegate {
    public func mediaItemTapped(_ data: MediaItem) {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        let landscapeVC = PlayerVC(data: data, info: infoData)
        landscapeVC.modalPresentationStyle = .fullScreen
        navController.navigationBar.isHidden = true
        navController.present(landscapeVC, animated: true, completion: nil)
    }
}
