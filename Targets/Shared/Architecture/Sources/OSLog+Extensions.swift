//
//  OSLog+Extensions.swift
//
//
//  Created by Inumaki on 21.10.23.
//

import Foundation
import OSLog

extension OSLog {
  private static var subsystem = Bundle.main.bundleIdentifier.unsafelyUnwrapped

  /// Creates a custom log category for URLRequest logging.
  public static let urlRequest = OSLog(subsystem: subsystem, category: "URLRequest")

  public static let webview = OSLog(subsystem: subsystem, category: "Webview")

  public static let downloadManager = OSLog(subsystem: subsystem, category: "DownloadManager")
}
