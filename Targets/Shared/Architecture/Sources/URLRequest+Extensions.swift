//
//  URLRequest+Extensions.swift
//
//
//  Created by Inumaki on 21.10.23.
//

import Foundation
import OSLog

extension URLRequest {
  /// Logs the details of the URLRequest including the status code using OSLog.
  public func log(response: HTTPURLResponse? = nil) {
    // Get the HTTP method and URL
    let method = httpMethod ?? "N/A"
    let url = url?.absoluteString ?? "N/A"

    // Create a formatted log message
    var logMessage = "URLRequest: [Method: \(method), URL: \(url)]"

    // Include the status code if available
    if let response {
      let statusCode = response.statusCode
      logMessage.append(", Status Code: \(statusCode)")
    }

    // Log the message using OSLog
    os_log("%{public}@", log: OSLog.urlRequest, type: .info, logMessage)
  }
}
