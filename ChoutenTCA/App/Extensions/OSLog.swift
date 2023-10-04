//
//  OSLog.swift
//  ChoutenTCA
//
//  Created by Inumaki on 03.10.23.
//

import Foundation
import OSLog

extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Creates a custom log category for URLRequest logging.
    static let urlRequest = OSLog(subsystem: subsystem, category: "URLRequest")
}
