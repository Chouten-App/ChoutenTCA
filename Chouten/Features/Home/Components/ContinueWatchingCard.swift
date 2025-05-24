//
//  ContinueWatchingCard.swift
//  
//
//  Created by Inumaki on 9/7/24.
//

import Core
import UIKit

 class ContinueWatchingCard: UICollectionViewCell, SelfConfiguringCellHome {
    static var reuseIdentifier: String = "ContinueWatchingCard"
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let moduleImageView: UIImageView = {
        let view = UIImageView()
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
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Subtitle"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "12:01 / 24:02"
        label.font = .systemFont(ofSize: 10)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    let subtitleTimeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
    
     override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame to match the overlayView's bounds
        gradientLayer.frame = overlayView.bounds
    }
    
    func configure(with data: HomeData) {
        translatesAutoresizingMaskIntoConstraints = true
        backgroundColor = ThemeManager.shared.getColor(for: .container)
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 12
        clipsToBounds = true
        
        imageView.setAsyncImage(url: data.poster)
        
        // Set module icon if moduleId is available
        if let moduleId = data.moduleId {
            Chouten.getModuleIconData(for: moduleId) { [weak self] iconPath in
                if let iconPath = iconPath, let image = UIImage(contentsOfFile: iconPath) {
                    self?.moduleImageView.image = image
                } else {
                    // Fallback to Chouten logo if module icon not found
                    self?.moduleImageView.setAsyncImage(url: "https://www.chouten.app/Icon.png")
                }
            }
        } else {
            // Fallback to Chouten logo if no moduleId
            moduleImageView.setAsyncImage(url: "https://www.chouten.app/Icon.png")
        }
        
        titleLabel.text = data.titles.primary
        subtitleLabel.text = data.titles.secondary ?? ""
        timeLabel.text = data.indicator
        
        // Set the progress bar value
        if let current = data.current, let total = data.total, total > 0 {
            let progress = Double(current) / Double(total)
            progressView.updateProgress(progress)
            print("Setting progress for \(data.titles.primary): \(progress) (\(current)/\(total))")
        } else {
            // Default to no progress if missing values
            progressView.updateProgress(0)
        }
        
        addSubview(imageView)
        overlayView.addSubview(titleLabel)
        
        // Add subtitle and time labels to the stack view
        subtitleTimeStack.addArrangedSubview(subtitleLabel)
        subtitleTimeStack.addArrangedSubview(timeLabel)
        overlayView.addSubview(subtitleTimeStack)
        
        overlayView.addSubview(progressView)
        addSubview(overlayView)
        
        addSubview(moduleImageView)
        
        setupConstraints()
        setupGradient()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 280),
            heightAnchor.constraint(equalToConstant: 190),
            
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Subtitle and time stack view
            subtitleTimeStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleTimeStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            subtitleTimeStack.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -8),
            
            // Title label constraints with proper spacing
            titleLabel.bottomAnchor.constraint(equalTo: subtitleTimeStack.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
            
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
