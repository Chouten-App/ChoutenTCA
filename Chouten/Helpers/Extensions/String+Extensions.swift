//
//  String+Extensions.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
