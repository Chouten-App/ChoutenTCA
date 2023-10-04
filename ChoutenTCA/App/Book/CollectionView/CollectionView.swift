//
//  CollectionView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 19.09.23.
//

import SwiftUI
import Kingfisher
import UIKit

enum ReadingMode {
    case ltr
    case rtl
    case vertical
}

// Create a UIViewRepresentable for UICollectionView
struct ImageCollectionView: UIViewRepresentable {
    
    // Your data source containing image URLs as strings
    var imageUrls: [ImageData]
    @Binding var readingMode: ReadingMode
    
    // Binding to store the current cell index
    @Binding var currentCellIndex: Int
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout: UICollectionViewFlowLayout
        if readingMode == .vertical {
            layout = UICollectionViewFlowLayout()
        } else {
            layout = SnappingCollectionViewLayout()
        }
        
        layout.minimumInteritemSpacing = 0 // Remove horizontal spacing between cells
        layout.minimumLineSpacing = 0 // Remove vertical spacing between cells
        layout.scrollDirection = readingMode == .vertical ? .vertical : .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPrefetchingEnabled = true
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .clear
        
        if readingMode != .vertical {
            collectionView.decelerationRate = .fast
        }
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        // Set semanticContentAttribute for the parent UIView
        if readingMode == .rtl {
            collectionView.superview?.semanticContentAttribute = .forceRightToLeft
        }
        
        return collectionView
    }

    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        // Reload the collection view when data changes
        uiView.reloadData()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator to handle collection view data source and delegate
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        var parent: ImageCollectionView
        
        // Store image sizes for each item
        var imageSizes: [CGSize?]
        var lastVisibleIndex: Int = 0
        
        init(_ parent: ImageCollectionView) {
            self.parent = parent
            self.imageSizes = Array(repeating: nil, count: parent.imageUrls.count)
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return parent.imageUrls.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            let imageUrlString = parent.imageUrls[indexPath.item].image
            if let imageUrl = URL(string: imageUrlString) {
                cell.imageView.kf.setImage(with: imageUrl)
            }
            cell.transform = CGAffineTransform(scaleX: self.parent.readingMode == .rtl ? -1 : 1, y: 1)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let screenWidth = collectionView.bounds.width
            let screenHeight = collectionView.bounds.height
            let imageUrlString = parent.imageUrls[indexPath.item].image
            
            if let imageUrl = URL(string: imageUrlString) {
                // Use Kingfisher's retrieveImage method to load the image asynchronously
                KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
                    switch result {
                    case .success(let value):
                        if self.parent.readingMode == .vertical {
                            // Calculate the cell height based on the loaded image's aspect ratio
                            let aspectRatio = value.image.size.width / value.image.size.height
                            let cellHeight = screenWidth / aspectRatio
                            // Update cell height asynchronously
                            DispatchQueue.main.async {
                                self.imageSizes[indexPath.item] = CGSize(width: screenWidth, height: cellHeight)
                                collectionView.collectionViewLayout.invalidateLayout()
                            }
                        }
                        break
                    case .failure(let error):
                        print("Error loading image: \(error)")
                    }
                }
            }
            
            if self.parent.readingMode == .vertical {
                if let size = imageSizes[indexPath.item] {
                    // Return the calculated size if available
                    return size
                }
                return CGSize(width: screenWidth, height: 100)
            }
            
            return CGSize(width: screenWidth, height: screenHeight)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let collectionView = scrollView as? UICollectionView else {
                    return
                }

                let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
                let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

                if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
                    if indexPath.item != lastVisibleIndex {
                        parent.currentCellIndex = indexPath.item
                        lastVisibleIndex = indexPath.item
                    }
                }
            
        }
    }
}

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Update cell height after loading the image
    func updateHeight(_ height: CGFloat) {
        imageView.frame.size.height = height
    }
}

#Preview {
    ImageCollectionView(
        imageUrls: [
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x1-746048af037c46657cc768149fddfa401c68834789d35579eecc8f1bb104f205.png"),
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x2-04665d25774fb5a82ba6679194d4fbede30d972d808334e7f98784312b173e04.jpg"),
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x3-5dcb54d2bca1110b27bb7547d98b16be45f2de86393cbcc7d633063f7bf2d17d.jpg"),
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x4-e5217db5e4f441e516b4dfea0b732db5c871edb3ff1794684070709eecea21a1.png"),
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x5-f533182efdac3973963da7d458deb50762211c4995f7d6ce99416314ddef655c.png"),
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x6-698ddfccbab5c5de958e1efbadbc51bcfd4632b7b6b495e3bb5c2922309912e0.png"),
            ImageData(id: UUID().uuidString, image: "https://uploads.mangadex.org/data/d55bbdf2c116189e54ab1e38a5480aa3/x7-1109c741386cb071ba5b3baf1c4aa8bc019c859bd8b733149d1f909359d53cc6.png")
        ],
        readingMode: .constant(.vertical),
        currentCellIndex: .constant(0)
    )
    .ignoresSafeArea()
}
