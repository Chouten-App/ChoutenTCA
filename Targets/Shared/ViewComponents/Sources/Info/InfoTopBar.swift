//
//  InfoTopBar.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 06.02.24.
//

import Architecture
import UIKit

extension UIView {
    func snapshotWithGaussianBlur(radius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        guard let snapshot = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()

        let ciImage = CIImage(image: snapshot)
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)

        guard let outputCIImage = filter?.outputImage else { return nil }
        let context_new = CIContext(options: nil)
        guard let outputCGImage = context_new.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }
}

public class InfoTopBar: UIView {

    let title: String

    let wrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let blurView: UIVisualEffectView = {
        let effect              = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view                = UIVisualEffectView(effect: effect)
        view.layer.borderColor  = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth  = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = effect }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }()

    let backButton = CircleButton(icon: "chevron.left")
    public var bookmarkButton = CircleButton(icon: "bookmark")

    public let titleLabel: UILabel = {
        let label           = UILabel()
        label.textColor     = ThemeManager.shared.getColor(for: .fg)
        label.font          = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        label.lineBreakStrategy = []
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let horizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let titleHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let marqueeWrapper = UIView()

    public init(title: String) {
        self.title = title
        super.init(frame: .zero)
        configure()
        setupConstraints()
    }

    override public init(frame: CGRect) {
        self.title = "Title"
        super.init(frame: frame)
        configure()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        titleHorizontalStack.addArrangedSubview(titleLabel)
        titleHorizontalStack.addArrangedSubview(bookmarkButton)
        
        marqueeWrapper.clipsToBounds = true
        marqueeWrapper.translatesAutoresizingMaskIntoConstraints = false
        marqueeWrapper.addSubview(titleHorizontalStack)

        translatesAutoresizingMaskIntoConstraints = false

        wrapper.addSubview(blurView)

        horizontalStack.addArrangedSubview(backButton)

        wrapper.addSubview(horizontalStack)
        wrapper.addSubview(marqueeWrapper)
        addSubview(wrapper)

        // update title
        titleLabel.text = title

        titleLabel.alpha = 0.0
        blurView.alpha = 0.0

        backButton.onTap = {
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let navController = window.rootViewController as? UINavigationController {
                navController.popViewController(animated: true)
            }
        }
    }

    // MARK: Layout
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
            wrapper.topAnchor.constraint(equalTo: topAnchor),
            wrapper.bottomAnchor.constraint(equalTo: bottomAnchor),

            blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -1),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 1),
            blurView.topAnchor.constraint(equalTo: topAnchor, constant: -1),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            horizontalStack.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            horizontalStack.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),

            marqueeWrapper.topAnchor.constraint(equalTo: backButton.topAnchor),
            marqueeWrapper.bottomAnchor.constraint(equalTo: backButton.bottomAnchor),
            marqueeWrapper.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            marqueeWrapper.trailingAnchor.constraint(equalTo: blurView.trailingAnchor, constant: -20),

            titleHorizontalStack.centerYAnchor.constraint(equalTo: marqueeWrapper.centerYAnchor),
            titleHorizontalStack.leadingAnchor.constraint(equalTo: marqueeWrapper.leadingAnchor),
            titleHorizontalStack.trailingAnchor.constraint(equalTo: marqueeWrapper.trailingAnchor)
        ])
    }
}
