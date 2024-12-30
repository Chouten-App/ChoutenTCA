//
//  SelfConfiguringCell.swift
//  ViewComponents
//
//  Created by Inumaki on 13.07.24.
//

import Core
import Foundation

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }

    func configure(with data: DiscoverData)
}
