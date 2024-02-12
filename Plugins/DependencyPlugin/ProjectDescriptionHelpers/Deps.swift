//
//  Deps.swift
//  DependencyPlugin
//
//  Created by ErrorErrorError on 1/31/24.
//
//

import Foundation
import ProjectDescription

extension TargetDependency {
  public static let features = Features.self
  public static let clients = Clients.self
  public static let shared = Shared.self
  public static let externalDependencies = ExternalDependencies.self
}

// MARK: - Features

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

// MARK: - Clients

public enum Clients: String, CaseIterable, QualifiedName {
  case buildClient
  case dataClient
  case fileClient
  case moduleClient

  public var project: TargetDependency {
    .project(target: name, path: .relativeToRoot("Targets/Clients/\(name)"))
  }
}

// MARK: - Shared

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
  public static let ascollectionView = Self(.external(name: "ASCollectionView"))
  public static let casePaths = Self(.external(name: "CasePaths"))
  public static let composableArchitecture = Self(.external(name: "ComposableArchitecture"))
  public static let dependenciesMacros = Self(.external(name: "DependenciesMacros"))
  public static let grdb = Self(.external(name: "GRDB"))
  public static let kingfisher = Self(.external(name: "Kingfisher"))
  public static let nuke = Self(.external(name: "Nuke"))
  public static let nukeUI = Self(.external(name: "NukeUI"))
  public static let swiftSoup = Self(.external(name: "SwiftSoup"))
  public static let semver = Self(.external(name: "Semver"))
  public static let shimmer = Self(.external(name: "Shimmer"))
  public static let tagged = Self(.external(name: "Tagged"))
  public static let texture = Self(.external(name: "Texture"))
  public static let zipFoundation = Self(.external(name: "ZIPFoundation"))
}
