//
//  SwiftUIView.swift
//
//
//  Created by Inumaki on 16.10.23.
//

import SwiftUI
import Kingfisher
import UIKit
import ComposableArchitecture

class SnappingCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity) }
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        
        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}

public struct ImageCellContentView: View {
    public var body: some View {
        ZStack {
            KFImage(
                URL(string: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg")
            )
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: 360)
            .clipped()
            
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("Primary")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Secondary")
                            .fontWeight(.semibold)
                            .opacity(0.7)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Icon Text")
                            .font(.caption)
                        
                        Image(systemName: "star.fill")
                            .font(.caption)
                    }
                }
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                    .font(.subheadline)
                    .lineLimit(3)
                    .opacity(0.7)
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width, height: 360, alignment: .bottomLeading)
            .background {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.7), location: 0.0),
                        .init(color: .black.opacity(0.0), location: 1.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 360)
    }
}

class ImageCell: UICollectionViewCell {
    var uiHostingController: UIHostingController<ImageCellContentView>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIHostingController()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUIHostingController()
    }
    
    private func setupUIHostingController() {
        let hostingController = UIHostingController(rootView: ImageCellContentView())
        hostingController.view.frame = bounds
        hostingController.view.backgroundColor = .clear
        contentView.addSubview(hostingController.view)
        uiHostingController = hostingController
    }
}

public struct Carousel: UIViewRepresentable {
    // Binding to store the current cell index
    let count: Int
    @Binding public var currentCellIndex: Int
    
    public init(count: Int, currentCellIndex: Binding<Int>) {
        self.count = count
        self._currentCellIndex = currentCellIndex
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        let layout = SnappingCollectionViewLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPrefetchingEnabled = true
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.backgroundColor = .clear
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.reloadData()
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        public var parent: Carousel
        
        public var lastVisibleIndex: Int = 0
        
        public init(_ parent: Carousel) {
            self.parent = parent
        }
        
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return parent.count
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            return cell
        }
        
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let screenWidth = collectionView.bounds.width
            return CGSize(width: screenWidth, height: 360)
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let collectionView = scrollView as? UICollectionView else {
                return
            }
            
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            
            if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
                if indexPath.item != lastVisibleIndex {
                    parent.currentCellIndex = indexPath.item
                    print(indexPath.item)
                    lastVisibleIndex = indexPath.item
                }
            }
        }
    }
}


#Preview("Carousel") {
    Carousel(count: 6, currentCellIndex: .constant(0))
        .frame(maxWidth: .infinity, maxHeight: 360)
}
