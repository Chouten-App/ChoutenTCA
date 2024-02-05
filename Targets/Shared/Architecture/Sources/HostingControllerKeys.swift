//
//  HostingControllerKeys.swift
//
//
//  Created by Inumaki on 05.11.23.
//

import SwiftUI

// MARK: - HomeIndicatorAutoHiddenPreferenceKey

public struct HomeIndicatorAutoHiddenPreferenceKey: PreferenceKey {
  public static var defaultValue = false

  public static func reduce(
    value: inout Bool,
    nextValue: () -> Bool
  ) {
    value = nextValue()
  }
}

// MARK: - SupportedOrientationPreferenceKey

public struct SupportedOrientationPreferenceKey: PreferenceKey {
  public static var defaultValue: UIInterfaceOrientationMask = .portrait

  public static func reduce(
    value: inout UIInterfaceOrientationMask,
    nextValue: () -> UIInterfaceOrientationMask
  ) {
    value = nextValue()
  }
}

extension View {
  public func prefersHomeIndicatorAutoHidden(_ value: Bool) -> some View {
    preference(key: HomeIndicatorAutoHiddenPreferenceKey.self, value: value)
  }

  public func supportedOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
    preference(key: SupportedOrientationPreferenceKey.self, value: orientation)
  }
}
