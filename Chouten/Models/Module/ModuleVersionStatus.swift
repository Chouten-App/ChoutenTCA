//
//  ModuleVersionStatus.swift
//  Chouten
//
//  Created by Inumaki on 19/10/2024.
//

import Foundation

 enum ModuleVersionStatus: Hashable, Equatable, Codable, Sendable {
    case upToDate
    case uninstalled
    case updateAvailable
}
