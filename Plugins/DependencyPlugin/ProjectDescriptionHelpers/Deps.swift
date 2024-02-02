//
//  Deps.swift
//  DependencyPlugin
//
//  Created by ErrorErrorError on 1/31/24.
//  
//

import Foundation
import ProjectDescription

public extension TargetDependency {
  static let features = Features.self
  static let clients = Clients.self
  static let shared = Shared.self
  static let externalDependencies = ExternalDependencies.self
}

public enum Features: String, CaseIterable, QualifiedName {
  case app
  case appearance
  case discover
  case home
  case info
  case moduleSheet
  case more
  case player
  case repo
  case search
  case webview

  public var project: TargetDependency {
    .project(target: name, path: .relativeToRoot("Targets/Features/\(name)"))
  }
}

public enum Clients: String, CaseIterable, QualifiedName {
  case dataClient
  case fileClient
  case moduleClient

  public var project: TargetDependency {
    .project(target: name, path: .relativeToRoot("Targets/Clients/\(name)"))
  }
}

public enum Shared: String, CaseIterable, QualifiedName {
  case architecture
  case foundationHelpers
  case sharedModels
  case viewComponents

  public var project: TargetDependency {
    .project(target: name, path: .relativeToRoot("Targets/Shared/\(name)"))
  }
}

extension ExternalDependencies {
//  public static let allCases: [ExternalDependencies] = [
//    ascollectionView,
//    composableArchitecture,
//    grdb,
//    kingfisher,
//    nukeUI,
//    swiftSoup,
//    shimmer,
//    texture,
//    zipFoundation
//  ]

  public static let ascollectionView = Self(.external(name: "ASCollectionView"))
  public static let composableArchitecture = Self(.external(name: "ComposableArchitecture"))
  public static let grdb = Self(.external(name: "GRDB"))
  public static let kingfisher = Self(.external(name: "Kingfisher"))
  public static let nuke = Self(.external(name: "Nuke"))
  public static let nukeUI = Self(.external(name: "NukeUI"))
  public static let swiftSoup = Self(.external(name: "SwiftSoup"))
  public static let shimmer = Self(.external(name: "Shimmer"))
  public static let texture = Self(.external(name: "Texture"))
  public static let zipFoundation = Self(.external(name: "ZIPFoundation"))
}
