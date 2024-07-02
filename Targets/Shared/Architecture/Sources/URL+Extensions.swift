//
//  URL+Extensions.swift
//  Architecture
//
//  Created by Inumaki on 20.06.24.
//

import Foundation

public extension URL {
    func getDomain() -> String? {
        // Ensure the urlString is a valid URL
        guard let host = self.host else {
            return nil
        }

        // Split the host into components
        let components = host.components(separatedBy: ".")

        // Ensure there are at least two components for a valid domain
        guard components.count >= 2 else {
            return nil
        }

        // Return the domain, assuming the last two components are the domain and top-level domain (TLD)
        return components.suffix(2).joined(separator: ".")
    }
}
