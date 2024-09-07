//
//  ContinueWatchingCard.swift
//  
//
//  Created by Inumaki on 9/7/24.
//

import Architecture
import SharedModels
import UIKit
import ViewComponents

class AsyncImageView: UIImageView {
    private var currentURL: URL?
    
    // Function to load image from a URL string
    func loadImage(from urlString: String, placeholder: UIImage? = nil) {
        // Set placeholder image while the actual image loads
        self.image = placeholder
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            return
        }
        
        // Keep track of the URL in case it's changed before the request finishes
        currentURL = url
        
        // Create a URL session to download the image data asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Check for errors or invalid data
            if let error = error {
                print("Failed to load image: \(error)")
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                return
            }
            
            // Ensure we're still expecting the image from this URL (in case of reused cells, etc.)
            if url == self?.currentURL {
                DispatchQueue.main.async {
                    self?.image = downloadedImage
                }
            }
        }.resume()
    }
    
    // Optionally, you can cancel any ongoing request if the view is reused or deallocated
    func cancelLoading() {
        currentURL = nil
    }
}

public class ContinueWatchingCard: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "ContinueWatchingCard"
    
    let imageView: AsyncImageView = {
        let view = AsyncImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let moduleImageView: AsyncImageView = {
        let view = AsyncImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtitle"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:01 / 24:02"
        label.font = .systemFont(ofSize: 10)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let progressView = ProgressBar()
    
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGradient() {
        gradientLayer.colors = [
            ThemeManager.shared.getColor(for: .container).withAlphaComponent(0.0).cgColor,
            ThemeManager.shared.getColor(for: .container).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        overlayView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame to match the overlayView's bounds
        gradientLayer.frame = overlayView.bounds
    }
    
    func configure(with data: HomeData) {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.shared.getColor(for: .container)
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 12
        clipsToBounds = true
        
        imageView.loadImage(from: data.poster, placeholder: UIImage(named: "placeholder"))
        moduleImageView.loadImage(from: "https://www.chouten.app/Icon.png", placeholder: UIImage(named: "placeholder"))
        
        titleLabel.text = data.titles.primary
        
        addSubview(imageView)
        overlayView.addSubview(titleLabel)
        overlayView.addSubview(subtitleLabel)
        overlayView.addSubview(timeLabel)
        overlayView.addSubview(progressView)
        addSubview(overlayView)
        
        addSubview(moduleImageView)
        
        setupConstraints()
        setupGradient()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 240),
            heightAnchor.constraint(equalToConstant: 180),
            
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8),
            
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            timeLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8),
            
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            moduleImageView.widthAnchor.constraint(equalToConstant: 40),
            moduleImageView.heightAnchor.constraint(equalToConstant: 40),
            moduleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            moduleImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        ])
    }
}
