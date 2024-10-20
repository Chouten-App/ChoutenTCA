//
//  JSValueError.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

struct JSValueError: Error, LocalizedError, CustomStringConvertible {
    var functionName: String?
    var name: String?
    var errorDescription: String?
    var failureReason: String?
    var stackTrace: String?

    init(_ value: JSValue, _ functionName: String? = nil, stackTrace: Bool = true) {
        self.functionName = functionName
        self.name = value["name"]?.toString()
        self.errorDescription = value["message"]?.toString()
        self.failureReason = value["cause"]?.toString()
        if stackTrace {
            self.stackTrace = value["stack"]?.toString()
        }
    }

    var description: String {
    """
    Instance\(functionName.flatMap { ".\($0)" } ?? "") => \
    \(name ?? "Error"): \(errorDescription ?? "No Message") \
    \(failureReason.flatMap { "    \($0)" } ?? "")
    """
    }
}
