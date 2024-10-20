//
//  DiscoverLoadingView.swift
//  Discover
//
//  Created by Inumaki on 18.06.24.
//

import UIKit

 class DiscoverLoadingView: UIViewController {
     let scrollView: UIScrollView = {
        let scrollView                          = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical         = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let contentView: UIStackView = {
        let view        = UIStackView()
        view.axis       = .vertical
        view.spacing    = 20  // Adjust the spacing between cards
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let scrollViewCarousel: UIScrollView = {
        let scrollView                              = UIScrollView()
        scrollView.isPagingEnabled                  = true
        scrollView.showsHorizontalScrollIndicator   = false
        scrollView.clipsToBounds                    = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    let carousel: UIStackView = {
        let view        = UIStackView()
        view.axis       = .horizontal
        view.spacing    = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override   func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupConstraints()

        addShimmerViews()
    }

    private func configure() {
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Adding multiple cards to the stack view
        contentView.addArrangedSubview(scrollViewCarousel)
        scrollViewCarousel.addSubview(carousel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            scrollViewCarousel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            scrollViewCarousel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollViewCarousel.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollViewCarousel.heightAnchor.constraint(equalToConstant: 460), // Adjusted height for visibility

            carousel.leadingAnchor.constraint(equalTo: scrollViewCarousel.contentLayoutGuide.leadingAnchor),
            carousel.trailingAnchor.constraint(equalTo: scrollViewCarousel.contentLayoutGuide.trailingAnchor),
            carousel.topAnchor.constraint(equalTo: scrollViewCarousel.contentLayoutGuide.topAnchor),
            carousel.bottomAnchor.constraint(equalTo: scrollViewCarousel.contentLayoutGuide.bottomAnchor)
        ])
    }

    private func addShimmerViews() {
        DispatchQueue.main.async {
            let wrapper = UIView()
            wrapper.translatesAutoresizingMaskIntoConstraints = false

            let card = UIView()
            card.backgroundColor = ThemeManager.shared.getColor(for: .container)
            card.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            card.layer.borderWidth = 0.5
            card.layer.cornerRadius = 12
            card.translatesAutoresizingMaskIntoConstraints = false

            let button = UIView()
            button.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
            button.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            button.layer.borderWidth = 0.5
            button.layer.cornerRadius = 16
            button.translatesAutoresizingMaskIntoConstraints = false

            wrapper.addSubview(card)
            wrapper.addSubview(button)

            self.carousel.addArrangedSubview(wrapper)
            self.carousel.isUserInteractionEnabled = false

            NSLayoutConstraint.activate([
                wrapper.widthAnchor.constraint(equalTo: self.scrollViewCarousel.frameLayoutGuide.widthAnchor),
                wrapper.heightAnchor.constraint(equalToConstant: 440),

                card.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10),
                card.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -10),
                card.heightAnchor.constraint(equalToConstant: 440),

                button.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                button.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

                button.widthAnchor.constraint(equalToConstant: 32),
                button.heightAnchor.constraint(equalToConstant: 32)
            ])

            UIView.animate(withDuration: 1.2, delay: 0.0, options: [.autoreverse, .repeat]) {
                wrapper.alpha = 0.4
            }
        }

        DispatchQueue.main.async {
            let stack        = UIStackView()
            stack.axis       = .horizontal
            stack.distribution = .equalSpacing
            stack.spacing    = 0
            stack.translatesAutoresizingMaskIntoConstraints = false

            let sectionTitle = UIView()
            sectionTitle.backgroundColor = ThemeManager.shared.getColor(for: .container)
            sectionTitle.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            sectionTitle.layer.borderWidth = 0.5
            sectionTitle.layer.cornerRadius = 6
            sectionTitle.translatesAutoresizingMaskIntoConstraints = false

            let viewAllTitle = UIView()
            viewAllTitle.backgroundColor = ThemeManager.shared.getColor(for: .container)
            viewAllTitle.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
            viewAllTitle.layer.borderWidth = 0.5
            viewAllTitle.layer.cornerRadius = 6
            viewAllTitle.translatesAutoresizingMaskIntoConstraints = false

            stack.addArrangedSubview(sectionTitle)
            stack.addArrangedSubview(viewAllTitle)
            self.contentView.addArrangedSubview(stack)

            NSLayoutConstraint.activate([
                stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

                sectionTitle.heightAnchor.constraint(equalToConstant: 28),
                sectionTitle.widthAnchor.constraint(equalToConstant: 120),

                viewAllTitle.heightAnchor.constraint(equalToConstant: 20),
                viewAllTitle.widthAnchor.constraint(equalToConstant: 60)
            ])

            let cardHorizontalScrollview = UIScrollView()
            cardHorizontalScrollview.showsHorizontalScrollIndicator = false
            cardHorizontalScrollview.alwaysBounceHorizontal         = true
            cardHorizontalScrollview.clipsToBounds                  = false
            cardHorizontalScrollview.translatesAutoresizingMaskIntoConstraints = false

            let cardHorizontalStack = UIStackView()
            cardHorizontalStack.spacing = 12
            cardHorizontalStack.axis = .horizontal
            cardHorizontalStack.translatesAutoresizingMaskIntoConstraints = false

            cardHorizontalScrollview.addSubview(cardHorizontalStack)
            self.contentView.addArrangedSubview(cardHorizontalScrollview)

            NSLayoutConstraint.activate([
                cardHorizontalScrollview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
                cardHorizontalScrollview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
                cardHorizontalScrollview.heightAnchor.constraint(equalToConstant: 220),

                cardHorizontalStack.leadingAnchor.constraint(equalTo: cardHorizontalScrollview.contentLayoutGuide.leadingAnchor),
                cardHorizontalStack.trailingAnchor.constraint(equalTo: cardHorizontalScrollview.contentLayoutGuide.trailingAnchor),
                cardHorizontalStack.topAnchor.constraint(equalTo: cardHorizontalScrollview.contentLayoutGuide.topAnchor),
                cardHorizontalStack.bottomAnchor.constraint(equalTo: cardHorizontalScrollview.contentLayoutGuide.bottomAnchor)
            ])

            for index in 0..<20 {
                // shimmer card
                let cardStack = UIStackView()
                cardStack.spacing = 6
                cardStack.axis = .vertical
                cardStack.translatesAutoresizingMaskIntoConstraints = false

                let cardBg = UIView()
                cardBg.backgroundColor = ThemeManager.shared.getColor(for: .container)
                cardBg.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
                cardBg.layer.borderWidth = 0.5
                cardBg.layer.cornerRadius = 8
                cardBg.translatesAutoresizingMaskIntoConstraints = false

                cardStack.addArrangedSubview(cardBg)
                cardStack.isUserInteractionEnabled = false

                cardHorizontalStack.addArrangedSubview(cardStack)

                NSLayoutConstraint.activate([
                    cardStack.widthAnchor.constraint(equalToConstant: 100),

                    cardBg.widthAnchor.constraint(equalToConstant: 100),
                    cardBg.heightAnchor.constraint(equalToConstant: 150)
                ])

                UIView.animate(withDuration: 1.2, delay: 0.4 + (Double(index) * 0.2), options: [.autoreverse, .repeat]) {
                    cardStack.alpha = 0.4
                }
            }
        }
    }
}
