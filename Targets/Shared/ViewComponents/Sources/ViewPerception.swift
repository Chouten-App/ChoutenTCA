//
//  ViewPerception.swift
//  ViewComponents
//
//  Created by ErrorErrorError on 2/8/24.
//  
//

import ComposableArchitecture
import Foundation
import SwiftUI

@MainActor
private struct PerceptionTrackingModifier<V: View>: ViewModifier {
  let content: V

  func body(content: Content) -> some View {
    WithPerceptionTracking { content }
  }
}

extension View {
  @MainActor
  public func withPerceptionTracking() -> some View {
    modifier(PerceptionTrackingModifier(content: self))
  }
}
