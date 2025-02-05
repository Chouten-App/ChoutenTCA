//  AboutVC.swift
//  Chouten
//
//  Created by Resty 23.01.25.
//

import UIKit

class AboutVC: UIViewController {
    
    private let aboutDisplay = AboutDisplay()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)
        
        // Add AboutDisplay view to the controller's view
        view.addSubview(aboutDisplay)
        
        // Set constraints for AboutDisplay to position within the view
        aboutDisplay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aboutDisplay.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            aboutDisplay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            aboutDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            aboutDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
}

class AboutDisplay: UIView {

    private let profileCards: [ProfileCardData] = [
        ProfileCardData(name: "Eltik", role: "Contributor", imageUrl: "https://avatars.githubusercontent.com/u/76538547?v=4", githubUrl: "https://github.com/Eltik"),
        ProfileCardData(name: "Nabil", role: "Distributor", imageUrl: "https://avatars.githubusercontent.com/u/43651360?v=4", githubUrl: "https://github.com/Bilnaa"),
        ProfileCardData(name: "Resty", role: "Contributor", imageUrl: "https://avatars.githubusercontent.com/u/70033123?v=4", githubUrl: "https://github.com/Arthur-Ditte"),
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = ThemeManager.shared.getColor(for: .bg)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(profileCardTop)
        
        for profile in profileCards {
            let profileCardView = profileCardSmall(for: profile)
            stackView.addArrangedSubview(profileCardView)
        }
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
    
    
    @objc private func openGitHub(_ sender: UITapGestureRecognizer) {
        if let urlString = sender.view?.accessibilityLabel, let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat((profileCards.count + 1) * 80))
    }
}

