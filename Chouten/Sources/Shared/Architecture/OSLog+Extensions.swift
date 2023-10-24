//
//  File.swift
//  
//
//  Created by Inumaki on 21.10.23.
//

import Foundation
import OSLog

public extension OSLog {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Creates a custom log category for URLRequest logging.
    static let urlRequest = OSLog(subsystem: subsystem, category: "URLRequest")
    
    static let webview = OSLog(subsystem: subsystem, category: "Webview")
    
    static let downloadManager = OSLog(subsystem: subsystem, category: "DownloadManager")
}
