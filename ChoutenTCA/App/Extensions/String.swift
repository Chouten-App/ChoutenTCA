//
//  String.swift
//  ChoutenTCA
//
//  Created by Inumaki on 23.05.23.
//

import Foundation

extension String {
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        let versionDelimiter = "."

        var versionComponents = self.components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return self.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
}

extension String {
    func baseUrl() -> String? {
        if let url = URL(string: self) {
            // Extract the scheme, host, and port (if any)
            if let scheme = url.scheme, let host = url.host {
                var baseUrl = scheme + "://" + host
                
                // Append the port if it exists
                if let port = url.port {
                    baseUrl += ":\(port)"
                }
                
                return baseUrl
            }
        }
        
        return nil
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
