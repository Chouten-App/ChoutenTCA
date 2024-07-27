//
//  ReaderViewController.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 17.07.24.
//

import ComposableArchitecture
import SharedModels
import UIKit
import ViewComponents
import Nuke

public class ReaderViewController: UIViewController {
    let store: StoreOf<BookFeature>

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, ImageModel>!

    var currentChapter = 0

    var currentSection: Int = 0
    var currentIndex: Int = 0
    var lastFetchedIndex: Int = 0

    var prefetcher: ImagePrefetcher!

    var imageSizes: [IndexPath: CGSize] = [:]

    var mode: ReaderMode = .ltr

    let controls = ReaderControls()

    var showControls = true
    var isDragging = false

    var loadedInitialData: Bool = false
    var lastChapterLength = 0

    public init(infoData: InfoData, item: MediaItem, index: Int, mediaItems: [MediaItem]) {
        store = .init(
            initialState: .init(infoData: infoData, item: item, index: index, mediaItems: mediaItems),
            reducer: { BookFeature() }
        )
        super.init(nibName: nil, bundle: nil)

        currentIndex = index
        lastFetchedIndex = index

        observe { [weak self] in
            guard let self else { return }

            if store.chapters.count == 1 {
                loadInitialData()
            } else if store.chapters.count > 1 {
                addData()
            }
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        store.send(.view(.onAppear))

        prefetcher = ImagePrefetcher()

        let layout = mode == .rtl ? CustomCollectionViewFlowLayout() : UICollectionViewFlowLayout()

        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = mode == .webtoon || mode == .verticalPaged ? .vertical : .horizontal
        layout.sectionInset = UIEdgeInsets.zero

        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(ChapterFooterCell.self, forCellWithReuseIdentifier: "chapterFooter")
        collectionView.register(FirstChapterCell.self, forCellWithReuseIdentifier: "firstChapterCell")

        if mode != .webtoon {
            collectionView.isPagingEnabled = true
        }

        controls.titleLabel.text = store.infoData.titles.primary

        controls.seekbar.delegate = self

        self.view.addSubview(collectionView)
        self.view.addSubview(controls)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controls.topAnchor.constraint(equalTo: view.topAnchor),
            controls.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        configureDataSource()
        // loadInitialData()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        // collectionView.addGestureRecognizer(tapGesture)
        self.controls.blackOverlay.addGestureRecognizer(tapGesture)
    }

    @objc func toggleControls() {
        showControls.toggle()

        UIView.animate(withDuration: 0.2) {
            self.controls.alpha = self.showControls ? 1.0 : 0.0
        }
    }

    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ImageModel>(
            collectionView: collectionView
        ) { collectionView, indexPath, imageModel -> UICollectionViewCell? in
            self.currentSection = indexPath.section

            let totalItemsInSection = self.store.chapters[imageModel.chapter]?.count ?? 1
            print("IndexPath: \(indexPath.item), Section: \(indexPath.section), Total Items: \(totalItemsInSection)")

            self.currentIndex = self.store.mediaItems.firstIndex(where: { $0.number == imageModel.chapter }) ?? self.store.index

            if !self.isDragging {
                self.controls.updatePage(indexPath.item + 1, total: totalItemsInSection)

                UIView.animate(withDuration: 0.1) {
                    self.controls.seekbar.updateProgress(
                        Double((indexPath.item)) / Double(totalItemsInSection - 1)
                    )
                    self.controls.layoutIfNeeded()
                }
            }

            if imageModel.isFirstChapter {
                // swiftlint:disable force_cast
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapterFooter", for: indexPath) as! FirstChapterCell
                // swiftlint:enable force_cast
                cell.configure(imageModel.currentChapter)
                return cell
            }

            if indexPath.item == totalItemsInSection {
                print(self.currentIndex)
                print("load next chapter")
                if self.currentIndex - 1 >= 0 && self.currentIndex - 1 < self.store.mediaItems.count {
                    print(self.store.mediaItems[self.currentIndex - 1])
                    // load previous chapter
                    self.lastFetchedIndex = self.currentIndex - 1
                    self.store.send(
                        .view(
                            .loadChapter(
                                url: self.store.mediaItems[self.currentIndex - 1].url,
                                number: self.store.mediaItems[self.currentIndex - 1].number
                            )
                        )
                    )
                }

                // swiftlint:disable force_cast
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "chapterFooter", for: indexPath) as! ChapterFooterCell
                cell.configure(imageModel.nextChapter, oldChapterTitle: imageModel.currentChapter)
                // swiftlint:enable force_cast
                return cell
            } else {
                // swiftlint:disable force_cast
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
                // swiftlint:enable force_cast
                cell.configure(with: imageModel.url, isRTL: self.mode == .rtl)
                cell.imageLoadedCallback = { [weak self] image, url in
                    guard let self = self,
                            let image = image,
                          let chapters = self.store.chapters[imageModel.chapter],
                          chapters[indexPath.item].url == url else { return }
                    let aspectRatio = image.size.height / image.size.width
                    let width = collectionView.bounds.width
                    let height = width * aspectRatio
                    if self.imageSizes[indexPath] == nil {
                        self.imageSizes[indexPath] = CGSize(width: width, height: height)
                    }
                    DispatchQueue.main.async {
                        self.collectionView.collectionViewLayout.invalidateLayout()
                    }
                }
                return cell
            }
        }
    }

    func loadInitialData() {
        if loadedInitialData { return }
        print("loading data")
        loadedInitialData = true
        lastChapterLength = 1
        var snapshot = NSDiffableDataSourceSnapshot<Section, ImageModel>()
        snapshot.appendSections([.chapter(store.item.number)])

        if store.index == 0 {
            snapshot.appendItems(
                [
                    ImageModel(
                        url: "",
                        chapter: store.item.number,
                        currentChapter: store.item.title ?? "Chapter \(store.item.number.removeTrailingZeros())",
                        isFirstChapter: true
                    )
                ],
                toSection: .chapter(store.item.number)
            )
        }

        snapshot.appendItems(store.lastAppendedChapter)
        // Adding a placeholder for the footer cell
        let nextItem = store.index + 1 < store.mediaItems.count ? store.mediaItems[store.index + 1] : nil
        snapshot.appendItems(
            [
                ImageModel(
                    url: "",
                    chapter: store.item.number,
                    currentChapter: store.item.title ?? "Chapter \(store.item.number.removeTrailingZeros())",
                    nextChapter: nextItem?.title
                    ?? "Chapter \(nextItem?.number.removeTrailingZeros())"
                )
            ],
            toSection: .chapter(store.item.number)
        )
        self.dataSource.apply(snapshot, animatingDifferences: false) {
            // Scroll to the first cell of the initially loaded chapter
            let indexPath = IndexPath(item: self.store.index == 0 ? 1 : 0, section: 1)
            if let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) {
                let targetOffset = CGPoint(
                    x: attributes.frame.origin.x - (self.collectionView.bounds.size.width / 2) + (attributes.frame.size.width / 2),
                    y: self.collectionView.contentOffset.y
                )

                self.collectionView.setContentOffset(targetOffset, animated: false)
            }
        }

        if currentIndex + 1 > 0 && currentIndex + 1 < store.mediaItems.count {
            // load previous chapter
            lastFetchedIndex = currentIndex + 1
            print("Current index: \(currentIndex)")
            print("Fetching \(lastFetchedIndex)")
            store.send(.view(.loadChapter(url: store.mediaItems[lastFetchedIndex].url, number: store.mediaItems[lastFetchedIndex].number)))
        }
    }

    func addData() {
        print("adding new chapter")
        guard store.mediaItems.indices.contains(lastFetchedIndex) else {
            print("Next media item index out of bounds")
            return
        }

        print("Last index: \(lastFetchedIndex)")

        let nextMediaItem = store.mediaItems[lastFetchedIndex]
        let currentMediaItem = store.mediaItems[currentIndex]
        let newSection = Section.chapter(nextMediaItem.number)

        var snapshot = dataSource.snapshot()

        print("Current sections: \(snapshot.sectionIdentifiers)")

        // Check if the section already exists
        if snapshot.sectionIdentifiers.contains(newSection) {
            print("Section already exists: \(newSection)")
            return
        }

        // Insert the new section before the first section
        var inserted: Bool = false
        if nextMediaItem.number < currentMediaItem.number, let firstSection = snapshot.sectionIdentifiers.first {
            print("Inserting new section: \(newSection) before section: \(String(describing: snapshot.sectionIdentifiers.first))")
            snapshot.insertSections([newSection], beforeSection: firstSection)
            inserted = true
        } else {
            print("Appending new section: \(newSection)")
            snapshot.appendSections([newSection])
        }

        // Append items to the new section
        snapshot.appendItems(store.lastAppendedChapter, toSection: newSection)

        // Adding a placeholder for the footer cell
        snapshot.appendItems(
            [
                ImageModel(
                    url: "",
                    chapter: nextMediaItem.number,
                    currentChapter: currentMediaItem.title ?? "Chapter \(currentMediaItem.number.removeTrailingZeros())",
                    nextChapter: nextMediaItem.title ?? "Chapter \(nextMediaItem.number.removeTrailingZeros())"
                )
            ],
            toSection: newSection
        )

        // Apply the snapshot to the data source
        dataSource.apply(snapshot, animatingDifferences: false)

        if inserted {
            let indexPath = IndexPath(item: lastFetchedIndex == 0 ? 1 : 0, section: 1)
            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let targetOffset = CGPoint(
                    x: attributes.frame.origin.x - (collectionView.bounds.size.width / 2) + (attributes.frame.size.width / 2),
                    y: collectionView.contentOffset.y
                )

                self.collectionView.setContentOffset(targetOffset, animated: false)
            }
        }

        print("Updated sections: \(snapshot.sectionIdentifiers)")
    }
}

extension ReaderViewController: SeekBarDelegate {

    public func didStartDragging() {
        isDragging = true
    }

    public func didEndDragging() {
        isDragging = false
    }

    public func seekBar(_ seekBar: SeekBar, didChangeProgress progress: Double) {
        let totalItems = store.chapters[Double(currentSection)]?.count ?? 1
        let index = Int(progress * Double(totalItems))

        guard index < totalItems else { return }

        controls.updatePage(index + 1, total: totalItems)

        let indexPath = IndexPath(item: index, section: currentSection)
        // Calculate the target content offset
        if mode == .webtoon || mode == .verticalPaged {
            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let targetOffset = CGPoint(
                    x: collectionView.contentOffset.x,
                    y: attributes.frame.origin.y - (collectionView.bounds.size.height / 2) + (attributes.frame.size.height / 2)
                )

                // Animate the scrolling
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.setContentOffset(targetOffset, animated: false)
                })
            }
        } else {
            if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                let targetOffset = CGPoint(
                    x: attributes.frame.origin.x - (collectionView.bounds.size.width / 2) + (attributes.frame.size.width / 2),
                    y: collectionView.contentOffset.y
                )

                // Animate the scrolling
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionView.setContentOffset(targetOffset, animated: false)
                })
            }
        }
    }
}

extension ReaderViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (store.chapters[Double(section)]?.count ?? 1) + 1 // Adding one for the footer
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == (store.chapters[Double(indexPath.section)]?.count ?? 1) {
            // Size for the chapter footer
            return CGSize(width: collectionView.bounds.width, height: mode == .webtoon || mode == .verticalPaged ? 450 : UIScreen.main.bounds.height)
        } else {
            if let size = imageSizes[indexPath] {
                return size
            }
            // Default size while image is loading
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showControls.toggle()

        UIView.animate(withDuration: 0.2) {
            self.controls.alpha = self.showControls ? 1.0 : 0.0
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if mode == .webtoon || mode == .verticalPaged {
//            let offsetY = scrollView.contentOffset.y
//            let contentHeight = scrollView.contentSize.height
//
//            if offsetY > contentHeight - scrollView.frame.height {
//                // User scrolled to the bottom, load next chapter
//                if currentChapter == 0 {
//                    loadNextChapter()
//                }
//            }
//        } else {
//            let offsetX = scrollView.contentOffset.x
//            let contentWidth = scrollView.contentSize.width
//            print(offsetX)
//
//            if offsetX > contentWidth - scrollView.frame.width {
//                // User scrolled to the bottom, load next chapter
//                if currentChapter == 0 {
//                    loadNextChapter()
//                }
//            }
//        }
    }

    func loadNextChapter() {
        // Load next chapter data
//        currentChapter += 1
//        let nextChapterImages = [
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m1-53f741fee5ef9789f328e8fe932a0098d46d3d536787c2cae5ccba5d988a8653.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m2-6ab0dbf035970add2a4210b231e8b21b13b01e4b4398b7bd6f2397493770eeff.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m3-aab279a16e1ad05feba45dd2cae4128e90b3fc1db033dfa87ed067c523bc30c2.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m4-35c8f48ce015ca412660e1106eeafe8b2e4b68c58b60caa75e23dbc196cc9e52.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m5-0bcc489e463075448064739702fecc95f556fcfcb44a46a31f50567989b53952.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m6-2b1e9e0155ddad8517a524b1b66dc9d94cef778898ed7439a66c6f28595ab94c.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m7-e654e523eebe5d22d90a61cacfff993f90ea5df541fbe5f52a3246afed827a17.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m8-43bea4b9efd963c68bd4dd914e8990bf5dce4b06ef258d716a09e180cccc8432.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m9-3d894436acc5a6cc2a743cfd2c0b96a77315e9ffd625cc7331bf85f5e38f63fb.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m10-4ddaf6569347692625f1beb893736495bd8be7df0130165e3078bdf29abc0f74.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m11-76b03d5f23c0a6cf020e5b5808995734b278c3da1f211cbdb99d0a1fa7fe3ee7.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m12-4a14cd51cfaf0556d2eb5629498fb0b9abcf9b40e7faf6f4dead8a24339fad30.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m13-e1f39ec5e591697192d6313e6d0944051827e7ac179491acffce9b875a93393d.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m14-a843df0f8f0444655d87f938e18fd972bd4bb3c78c9c536f92da581bed5198de.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m15-1063d6259b579b01ac7bd75df91be48a9ef6d915552a7d1c9d59138bb6c85126.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m16-f03731a00e7652af1f93836412f3788d4d12f34f3c98a4b86c6330ea94321c1a.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m17-944f8244d2de37b9cb6e5a581f59f20030329988533b0f1bc3f1b8ab857e3b73.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m18-194bb7f450335d06be0897df35175ddad4e55e23d83eb618e3c34ffba45ffac0.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m19-180acd054ca159bd30cdc1d64db02df98302c1995ce4bb732f89c4532527c2a3.png",
//            "https://cmdxd98sb0x3yprd.mangadex.network/data/6302edfdaab1c76eec5f38aee968dc7c/m20-40ae04258d94528e315d453d3d7f1c57f405d7414e9177dba56bc214796ac1e8.png",
//
//            // Add URLs for the next chapter
//        ]
//        let nextChapter = nextChapterImages.map { ImageModel(url: $0, chapter: currentChapter) }
//        store.send(.view(.appendChapter(nextChapter)))
//        var snapshot = dataSource.snapshot()
//        snapshot.appendSections([.chapter(Double(currentChapter))])
//        snapshot.appendItems(nextChapter)
//        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ReaderViewController: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls: [URL] = indexPaths.compactMap { indexPath in
            if indexPath.item >= store.chapters[Double(indexPath.section)]?.count ?? 1 { return nil }
            if let chapters = store.chapters[Double(indexPath.section)] {
                return URL(string: chapters[indexPath.item].url)
            }
            return nil
        }
        prefetcher.startPrefetching(with: urls)
    }

    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls: [URL] = indexPaths.compactMap { indexPath in
            if let chapters = store.chapters[Double(indexPath.section)] {
                return URL(string: chapters[indexPath.item].url)
            }
            return nil
        }
        prefetcher.startPrefetching(with: urls)
    }
}
