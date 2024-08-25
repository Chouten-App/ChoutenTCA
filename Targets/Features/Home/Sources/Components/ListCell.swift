//
//  ListCell.swift
//  Home
//
//  Created by Inumaki on 13.07.24.
//

import Architecture
import SharedModels
import Info
import UIKit

class ListCell: UICollectionViewCell, SelfConfiguringCell {
    static let reuseIdentifier: String = "ListCellHome"
    
    var data: HomeData? = nil

    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = ThemeManager.shared.getColor(for: .container)
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let indicator: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let indicatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.fg
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.fg
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let whiteCircleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "circle.fill"))
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .systemBlue
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(whiteCircleImageView)
        contentView.addSubview(checkmarkImageView)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, countLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        indicator.addSubview(indicatorLabel)
        indicator.addSubview(indicatorImageView)
        imageView.addSubview(indicator)

        stackView.setCustomSpacing(4, after: imageView)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1

        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0.2

        addGestureRecognizer(tapGestureRecognizer)
        addGestureRecognizer(longPressGestureRecognizer)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 150),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),

            indicator.widthAnchor.constraint(equalToConstant: 24),
            indicator.heightAnchor.constraint(equalToConstant: 24),
            indicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            indicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            indicatorLabel.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
            indicatorLabel.centerYAnchor.constraint(equalTo: indicator.centerYAnchor),

            indicatorImageView.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
            indicatorImageView.centerYAnchor.constraint(equalTo: indicator.centerYAnchor),
            indicatorImageView.widthAnchor.constraint(equalToConstant: 18),
            indicatorImageView.heightAnchor.constraint(equalToConstant: 18),
            
            whiteCircleImageView.widthAnchor.constraint(equalToConstant: 32),
            whiteCircleImageView.heightAnchor.constraint(equalToConstant: 32),
            whiteCircleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            whiteCircleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            checkmarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with data: HomeData) {
        self.data = data
        
        imageView.setAsyncImage(url: data.poster)
        titleLabel.text = data.titles.primary
        countLabel.text = "\(data.current != nil ? String(data.current!) : "~")/\(data.total != nil ? String(data.total!) : "~")"

        if let indicator = ItemStatus(rawValue: data.indicator) {
            var symbolName: String {
                switch indicator {
                case .inprogress:
                    return "clock"  // You can randomly or conditionally choose between "clock", "hourglass", or "arrow.triangle.2.circlepath"
                case .completed:
                    return "checkmark.circle"  // Similarly, choose between "checkmark.circle", "checkmark.seal", or "flag.checkered"
                case .planned:
                    return "calendar.badge.clock"
                case .dropped:
                    return "xmark.circle"
                case .none:
                    return "minus.circle"
                }
            }
            
            var symbolColor: UIColor {
                switch indicator {
                case .inprogress:
                    return .yellow
                case .completed:
                    return .green
                case .planned:
                    return .yellow
                case .dropped:
                    return .red
                case .none:
                    return .white
                }
            }
            
            indicatorLabel.isHidden = true
            indicatorImageView.isHidden = false
            indicatorImageView.image = UIImage(systemName: symbolName)
            indicatorImageView.tintColor = symbolColor
        } else {
            indicatorLabel.text = data.indicator
            indicatorLabel.isHidden = false
            indicatorImageView.isHidden = true
        }
        indicator.alpha = data.indicator.isEmpty ? 0.0 : 1.0
    }
}

extension ListCell: UIGestureRecognizerDelegate {
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if let collectionView = self.superview?.superview as? UICollectionView,
           let homeView = collectionView.delegate as? HomeView {
            
            guard let indexPath = collectionView.indexPath(for: self) else { return }
            
            if homeView.isSelectionMode {
                if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
                    collectionView.deselectItem(at: indexPath, animated: true)
                    homeView.selectedItems.remove(indexPath)
                } else {
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
                    homeView.selectedItems.insert(indexPath)
                }
                homeView.updateUIForSelection()
            } else {
                // Perform the navigation as usual
                guard let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let window = scenes.windows.first,
                      let navController = window.rootViewController as? UINavigationController,
                      let data = self.data else {
                    return
                }
                
                let tempVC = InfoViewRefactor(url: data.url)
                navController.navigationBar.isHidden = true
                navController.pushViewController(tempVC, animated: true)
            }
        }
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // Apply a scale transform when the user taps or holds the card
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        case .ended, .cancelled:
            // Reset the scale transform when the tap or hold is released
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity
            }
        default:
            break
        }
    }

    // UIGestureRecognizerDelegate method to allow simultaneous recognition with other gestures
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Check if the other gesture is a pan gesture (likely the UIScrollView's pan gesture)
        if otherGestureRecognizer is UIPanGestureRecognizer {
            // If it's a pan gesture, prevent simultaneous recognition to avoid interference
            return false
        }
        // Otherwise, allow simultaneous recognition for other gestures
        return true
    }
    
    public func setSelected(_ selected: Bool) {
        DispatchQueue.main.async {
            if selected {
                UIView.animate(withDuration: 0.3) {
                    self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                    self.checkmarkImageView.isHidden = false
                    self.whiteCircleImageView.isHidden = false
                    self.checkmarkImageView.layer.zPosition = 99
                    self.whiteCircleImageView.layer.zPosition = 99
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.transform = .identity
                    self.checkmarkImageView.isHidden = true
                    self.whiteCircleImageView.isHidden = true
                    self.checkmarkImageView.layer.zPosition = 0
                    self.whiteCircleImageView.layer.zPosition = 0
                }
            }
        }
    }
}
