//
//  Loadable.swift
//
//
//  Created by Inumaki on 21.10.23.
//

import Foundation

// MARK: - Loadable

public enum Loadable<T> {
  case pending
  case loading
  case loaded(T)
  case failed(Error)

  public init(catching body: @Sendable () async throws -> T) async {
    self = .loading
    do {
      self = try await .loaded(body())
    } catch {
      self = .failed(error)
    }
  }

  @inlinable
  public init(_ result: Result<T, Error>) {
    switch result {
    case let .success(value):
      self = .loaded(value)
    case let .failure(error):
      self = .failed(error)
    }
  }

  @inlinable public var didFinish: Bool {
    switch self {
    case .pending, .loading:
      false
    default:
      true
    }
  }

  @inlinable public var value: T? {
    if case let .loaded(value) = self {
      return value
    }
    return nil
  }

  @inlinable public var isNotLoaded: Bool {
    if case .loaded = self {
      return false
    }
    return true
  }

  public var error: Error? {
    if case let .failed(error) = self {
      return error
    }
    return nil
  }

  public var hasInitialized: Bool {
    if case .pending = self {
      return false
    }
    return true
  }

  @inlinable
  public func map<V>(_ block: @escaping (T) -> V) -> Loadable<V> {
    switch self {
    case .pending:
      .pending
    case .loading:
      .loading
    case let .loaded(t):
      .loaded(block(t))
    case let .failed(e):
      .failed(e)
    }
  }

  @inlinable
  public func flatMap<V>(_ transform: (T) -> Loadable<V>) -> Loadable<V> {
    switch self {
    case .pending:
      .pending
    case .loading:
      .loading
    case let .loaded(value):
      transform(value)
    case let .failed(error):
      .failed(error)
    }
  }
}

// MARK: Equatable

extension Loadable: Equatable where T: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.loaded(lhs), .loaded(rhs)):
      lhs == rhs
    case let (.failed(lhs), .failed(rhs)):
      _isEqual(lhs, rhs)
    case (.loading, .loading), (.pending, .pending):
      true
    default:
      false
    }
  }
}

// MARK: Hashable

extension Loadable: Hashable where T: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .pending:
      hasher.combine(0)
    case .loading:
      hasher.combine(1)
    case let .loaded(value):
      hasher.combine(value)
      hasher.combine(2)
    case let .failed(error):
      if let error = (error as Any) as? AnyHashable {
        hasher.combine(error)
        hasher.combine(3)
      }
    }
  }
}

// MARK: Sendable

extension Loadable: Sendable where T: Sendable {}

private func _isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
  (lhs as? any Equatable)?.isEqual(other: rhs) ?? false
}

extension Equatable {
  fileprivate func isEqual(other: Any) -> Bool {
    self == other as? Self
  }
}
