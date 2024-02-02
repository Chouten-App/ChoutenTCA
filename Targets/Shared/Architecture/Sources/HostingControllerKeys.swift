//
//  File.swift
//  
//
//  Created by Inumaki on 05.11.23.
//

import SwiftUI

public struct HomeIndicatorAutoHiddenPreferenceKey: PreferenceKey {
    public static var defaultValue: Bool = false

    public static func reduce(
        value: inout Bool,
        nextValue: () -> Bool
    ) {
        value = nextValue()
    }
}

public struct SupportedOrientationPreferenceKey: PreferenceKey {
    public static var defaultValue: UIInterfaceOrientationMask = .portrait

    public static func reduce(
        value: inout UIInterfaceOrientationMask,
        nextValue: () -> UIInterfaceOrientationMask
    ) {
        value = nextValue()
    }
}

public extension View {
    func prefersHomeIndicatorAutoHidden(_ value: Bool) -> some View {
        preference(key: HomeIndicatorAutoHiddenPreferenceKey.self, value: value)
    }

    func supportedOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        preference(key: SupportedOrientationPreferenceKey.self, value: orientation)
    }
}
