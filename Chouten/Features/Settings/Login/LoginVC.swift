//
//  LoginVC.swift
//  Chouten
//
//  Created by Arthur Ditte on 27.12.24.
//


import UIKit

class LoginDisplay: UIView {

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),

        ])
        
    }
}

class LoginVC: UIViewController {

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.getColor(for: .bg)

        view.addSubview(scrollView)


        NSLayoutConstraint.activate([
        ])
    }

    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = ThemeManager.shared.getColor(for: .border)
        separator.alpha = 0.5
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.layer.cornerRadius = 0.5
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        return separator
    }
}

