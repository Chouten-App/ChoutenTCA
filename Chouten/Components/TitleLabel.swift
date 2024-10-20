//
//  TitleLabel.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import UIKit

enum TitleStyle {
    case subtitle
    case title
    case largeTitle
    case headline
    case caption
    case custom(_ size: Double)
    case customWithWeight(_ size: Double, weight: UIFont.Weight)
}

class TitleLabel: UILabel {
    init(_ text: String, style: TitleStyle) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        self.text = text
        textColor = .fg
        numberOfLines = 0
        
        switch style {
        case .subtitle:
            font = .systemFont(ofSize: 14, weight: .regular)
            alpha = 0.7
        case .title:
            font = .systemFont(ofSize: 18, weight: .bold)
        case .largeTitle:
            font = .systemFont(ofSize: 24, weight: .bold)
        case .headline:
            font = .systemFont(ofSize: 16, weight: .regular)
        case .caption:
            font = .systemFont(ofSize: 12, weight: .regular)
            alpha = 0.7
        case .custom(let size):
            font = .systemFont(ofSize: size, weight: .regular)
        case .customWithWeight(let size, let weight):
            font = .systemFont(ofSize: size, weight: weight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
