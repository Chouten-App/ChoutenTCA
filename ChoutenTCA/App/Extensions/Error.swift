//
//  Error.swift
//  ChoutenTCA
//
//  Created by Inumaki on 08.10.23.
//

import Foundation
import OSLog

extension Error {
    /// Logs the details of the error using OSLog.
    func log(logger: OSLog) {
        // Create a formatted log message with error details
        let errorDescription = self.localizedDescription
        let errorType = String(describing: type(of: self))
        
        let logMessage = "Error: [Type: \(errorType), Description: \(errorDescription)]"
        
        // Log the message using OSLog
        os_log("%{public}@", log: logger, type: .error, logMessage)
    }
}
