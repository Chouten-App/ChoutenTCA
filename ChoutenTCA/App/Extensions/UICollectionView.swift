//
//  UICollectionView.swift
//  ChoutenTCA
//
//  Created by Inumaki on 20.09.23.
//

import Foundation
import UIKit

extension UICollectionView {
    var visibleCurrentCellIndexPath: IndexPath? {
        for cell in self.visibleCells {
            let indexPath = self.indexPath(for: cell)
            return indexPath
        }
        
        return nil
    }
}
