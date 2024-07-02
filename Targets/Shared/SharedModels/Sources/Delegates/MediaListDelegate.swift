//
//  MediaListDelegate.swift
//  SharedModels
//
//  Created by Inumaki on 30.05.24.
//

import Foundation

public protocol MediaListDelegate: AnyObject {
    func mediaItemTapped(_ data: MediaItem)
}

public protocol MediaItemDelegate: AnyObject {
    func tapped(_ data: MediaItem)
}
