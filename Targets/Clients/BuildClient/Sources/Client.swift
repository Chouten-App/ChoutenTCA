//
//  Client.swift
//
//
//  Created by ErrorErrorError on 7/28/23.
//
//

import Dependencies
import Foundation
import Semver
import Tagged

public struct BuildKey: DependencyKey {
  public static let testValue = Build(
    version: Semver(0, 0, 0),
    number: 0
  )

  public static let liveValue = Build(
    version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
      .flatMap { $0 as? String }
      .flatMap { try? Semver($0) } ?? .init(0, 0, 0),
    number: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
      .flatMap { $0 as? String }
      .flatMap { Int($0) }
      .flatMap { .init(rawValue: $0) } ?? .init(0)
  )
}

extension DependencyValues {
  public var build: Build {
    get { self[BuildKey.self] }
    set { self[BuildKey.self] = newValue }
  }
}

public struct Build: Equatable, Sendable, CustomStringConvertible {
  public var version: Semver
  public var number: Number

  public typealias Number = Tagged<(Self, number: ()), Int>

  public var description: String {
    "\(version.description) (\(number.rawValue))"
  }
}

extension Semver: @unchecked Sendable {}
