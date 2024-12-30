//
//  MediaListDelegate.swift
//  Chouten
//
//  Created by Cel on 27/10/2024.
//

import Core
import Foundation

protocol MediaListDelegate: AnyObject {
    func mediaItemTapped(_ data: MediaItem, index: Int)
}

protocol MediaItemDelegate: AnyObject {
    func tapped(_ data: MediaItem, index: Int)
}
