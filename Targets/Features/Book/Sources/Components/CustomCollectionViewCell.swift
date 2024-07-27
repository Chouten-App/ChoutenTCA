//
//  CustomCollectionViewCell.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 19.07.24.
//

import Nuke
import UIKit
import ViewComponents

class CustomCollectionViewCell: UICollectionViewCell {

    let imageView = UIImageView()
    let progressView = CircularProgressView()
    var imageLoadedCallback: ((UIImage?, String) -> Void)?
    private var imageTask: ImageTask?

    var isRTL: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressView)

        NSLayoutConstraint.activate([

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 40),
            progressView.heightAnchor.constraint(equalToConstant: 40)
        ])

        addContextMenuInteraction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

//        if isRTL {
//            contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
//        }
    }

    func configure(with imageUrl: String, isRTL: Bool = false) {
        self.isRTL = isRTL

        if let url = URL(string: imageUrl) {
            progressView.isHidden = false
            progressView.progress = 0

            let request = ImageRequest(url: url)
            imageTask = Nuke.ImagePipeline.shared.loadImage(with: request, progress: { [weak self] _, completed, total in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.progressView.progress = CGFloat(completed) / CGFloat(total)
                }
            }, completion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.progressView.removeFromSuperview()
                    self.imageView.image = response.image
                    self.imageLoadedCallback?(response.image, url.absoluteString)
                case .failure(let error):
                    self.progressView.removeFromSuperview()
                    self.imageView.removeFromSuperview()
                    self.progressView.progress = 0.4
                    print("Failed to load image: \(error)")
                }
            })
        }
    }

    func addContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }
}

extension CustomCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let downloadAction = UIAction(title: "Download", image: UIImage(systemName: "arrow.down.circle")) { _ in
                self.handleDownload()
            }
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.handleShare()
            }
            return UIMenu(title: "", children: [downloadAction, shareAction])
        }

        return config
    }

    private func handleDownload() {
        // Handle image download
        print("Download action triggered")
    }

    private func handleShare() {
        // Handle image sharing
        print("Share action triggered")
    }
}
