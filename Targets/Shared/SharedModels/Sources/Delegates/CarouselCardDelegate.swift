//
//  CarouselCardDelegate.swift
//  SharedModels
//
//  Created by Inumaki on 15.04.24.
//

import Foundation

public protocol CarouselCardDelegate: AnyObject {
    func carouselCardDidTap(_ data: DiscoverData)
}
