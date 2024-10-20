//
//  ProgressBar.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//


import UIKit

class ProgressBar: UIView {
    let progress: Double = 0.5
    
    let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeManager.shared.getColor(for: .accent)
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = ThemeManager.shared.getColor(for: .container)
        layer.cornerRadius = 2
        layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        layer.borderWidth = 0.5
        
        addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.topAnchor.constraint(equalTo: topAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: progress)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
