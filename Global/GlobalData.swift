//
//  GlobalData.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation
import ComposableArchitecture

private enum GlobalDataKey: DependencyKey {
    static let liveValue = GlobalData.live
}
extension DependencyValues {
    var globalData: GlobalData {
        get { self[GlobalDataKey.self] }
        set { self[GlobalDataKey.self] = newValue }
    }
}

struct GlobalData {
    var module: Module?
}

extension GlobalData {
    static let live = Self(
        module: nil
    )
}
