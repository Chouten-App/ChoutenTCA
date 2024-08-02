//
//  SuccessInfoVC.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import Architecture
import RelayClient
import SharedModels
import UIKit
import Video
import ViewComponents
import Book

public protocol SuccessInfoVCDelegate: AnyObject {
    func fetchMedia(url: String, newIndex: Int)
    func fetchCollections() -> [HomeSection]
    func addItemToCollection(collection: HomeSection)
}

public class SuccessInfoVC: UIViewController {
    public weak var delegate: SuccessInfoVCDelegate?
    var infoData: InfoData
    var currentModuleType: ModuleType = .video

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

    var blurOverlay: UIImageView = {
        let view = UIImageView()
        view.contentMode = .top
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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

        seasonDisplay.infoData = infoData
        seasonDisplay.updateData()

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

                self.seasonSelector.updateData(with: self.infoData.seasons)

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
        seasonSelector.alpha = 0.0

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

        topBar.layer.zPosition = 10
        seasonSelector.layer.zPosition = 20
        seasonSelector.delegate = self
        
        headerDisplay.bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)

        view.addSubview(seasonSelector)

        setupConstraints()

        mediaListDisplay.delegate = self

        seasonDisplay.delegate = self

        seasonDisplay.seasonButton.onTap = {
            UIView.animate(withDuration: 0.2) {
                self.seasonSelector.alpha = 1.0
            }
        }
    }
    
    @objc func bookmarkButtonTapped() {
        let collections = delegate?.fetchCollections() ?? []
        let alert = UIAlertController(title: "Select Collection", message: "Choose a collection to add the item to:", preferredStyle: .actionSheet)

        for collection in collections {
            let action = UIAlertAction(title: collection.title, style: .default) { _ in
                self.delegate?.addItemToCollection(collection: collection)
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For iPad compatibility
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(alert, animated: true, completion: nil)
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

            seasonSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seasonSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seasonSelector.topAnchor.constraint(equalTo: view.topAnchor),
            seasonSelector.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

    private func takeScreenshot() -> UIImage {
        // Find the currently active scene
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first {
            let layer = window.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)

            if let context = UIGraphicsGetCurrentContext() {
                layer.render(in: context)
            }

            let screenshot = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
            UIGraphicsEndImageContext()

            return screenshot
        }

        return UIImage()
    }

    func addBlur(to image: UIImage) -> UIImage? {
        if let ciImage = CIImage(image: image) {
            ciImage.applyingFilter("CIGaussianBlur")
            return UIImage(ciImage: ciImage)
        }
        return nil
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
    public func mediaItemTapped(_ data: MediaItem, index: Int) {
        let scenes = UIApplication.shared.connectedScenes
        guard let windowScene = scenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let navController = window.rootViewController as? UINavigationController else {
            return
        }

        switch currentModuleType {
        case .video:
            let landscapeVC = PlayerVC(data: data, info: infoData, index: index)
            landscapeVC.modalPresentationStyle = .fullScreen
            navController.navigationBar.isHidden = true
            navController.present(landscapeVC, animated: true, completion: nil)
        case .book:
            print("Open Reader")
            // find media items list
            var mediaItems: [MediaItem] = []
            if let paginationWithItem = infoData.mediaList
                .flatMap({ $0.pagination })
                .first(where: { pagination in
                    pagination.items.contains(where: { $0 == data })
                }) {

                // Do something with the pagination
                mediaItems = paginationWithItem.items
            } else {
                print("Pagination containing the item not found.")
            }

            let readerVC = ReaderViewController(infoData: infoData, item: data, index: index, mediaItems: mediaItems)
            navController.navigationBar.isHidden = true
            navController.pushViewController(readerVC, animated: true)
        default:
            break
        }
    }
}

extension SuccessInfoVC: SeasonSelectorDelegate {
    public func didChangeSeason(to newIndex: Int) {
        if infoData.seasons.count > newIndex {
            delegate?.fetchMedia(url: infoData.seasons[newIndex].url, newIndex: newIndex)
        }
    }

    public func closeSelector() {
        UIView.animate(withDuration: 0.2) {
            self.seasonSelector.alpha = 0.0
        }
    }
}

extension SuccessInfoVC: SeasonDisplayDelegate {
    public func didChangePagination(to index: Int) {
        self.mediaListDisplay.updateData(with: index)
    }
}
