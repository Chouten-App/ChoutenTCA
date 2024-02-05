//
//  DragState.swift
//
//
//  Created by Inumaki on 27.10.23.
//

import Foundation

public enum DragState {
  case inactive
  case dragging(translation: CGSize)
}
