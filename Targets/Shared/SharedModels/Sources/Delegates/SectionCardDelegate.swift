//
//  SectionCardDelegate.swift
//  SharedModels
//
//  Created by Inumaki on 03.06.24.
//

import Foundation

public protocol SectionListDelegate: AnyObject {
    func didTap(_ data: DiscoverData)
}

public protocol SectionCardDelegate: AnyObject {
    func didTap(_ data: DiscoverData)
}
