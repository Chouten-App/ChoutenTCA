//
//  VideoLoadingError.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//

import Foundation

enum VideoLoadingError: Error {
  case invalidURL
  case networkError(Error)
  case dataParsingError(Error)
  case videoNotFound
  case unauthorized
  case other(Error)

  var localizedDescription: String {
    switch self {
    case .invalidURL:
      "Invalid URL"
    case let .networkError(underlyingError):
      "Network Error: \(underlyingError.localizedDescription)"
    case let .dataParsingError(underlyingError):
      "Data Parsing Error: \(underlyingError.localizedDescription)"
    case .videoNotFound:
      "Video not found"
    case .unauthorized:
      "Unauthorized access"
    case let .other(underlyingError):
      "An error occurred: \(underlyingError.localizedDescription)"
    }
  }
}
