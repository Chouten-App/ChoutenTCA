//
//  Models.swift
//  DependencyPlugin
//
//  Created by ErrorErrorError on 1/31/24.
//  
//

import Foundation
import ProjectDescription

public protocol QualifiedName {
  var name: String { get }
}

extension QualifiedName where Self: RawRepresentable, Self.RawValue == String {
  public var name: String { rawValue.pascalCase }
}

public struct ExternalDependencies {
  init(_ target: TargetDependency) {
    self.target = target
  }
  
  public let target: TargetDependency
}

extension String {
  var pascalCase: String { prefix(1).uppercased() + dropFirst() }
}
