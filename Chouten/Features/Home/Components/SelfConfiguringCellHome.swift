//
//  SelfConfiguringCell.swift
//  ViewComponents
//
//  Created by Inumaki on 13.07.24.
//

import Foundation

protocol SelfConfiguringCellHome {
    static var reuseIdentifier: String { get }

    func configure(with data: HomeData)
}
