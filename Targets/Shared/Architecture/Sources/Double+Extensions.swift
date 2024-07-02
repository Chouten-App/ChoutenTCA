//
//  Double+Extensions.swift
//  Architecture
//
//  Created by Inumaki on 23.03.24.
//

import Foundation

extension Double {
    public func removeTrailingZeros() -> String {
        String(format: "%g", self)
    }
}
