//
//  Project+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by ErrorErrorError on 1/30/24.
//
//

import DependencyPlugin
import ProjectDescription

extension Project {
  public static func feature(
    _ feature: Features,
    destinations: Destinations = Environments.destinations,
    deploymentTargets: DeploymentTargets = Environments.deploymentTargets,
    dependencies: [TargetDependency] = []
  ) -> Project {
    .init(
      name: feature.name,
      targets: [
        .init(
          name: feature.name,
          destinations: destinations,
          product: .framework,
          bundleId: "\(Environments.partialBundleId).\(feature.name)",
          deploymentTargets: deploymentTargets,
          sources: ["Sources/**"],
          dependencies: dependencies
        )
      ]
    )
  }

  public static func client(
    _ client: Clients,
    destinations: Destinations = Environments.destinations,
    deploymentTargets: DeploymentTargets = Environments.deploymentTargets,
    dependencies: [TargetDependency] = []
  ) -> Project {
    .init(
      name: client.name,
      targets: [
        .init(
          name: client.name,
          destinations: destinations,
          product: .framework,
          bundleId: "\(Environments.partialBundleId).\(client.name)",
          deploymentTargets: deploymentTargets,
          sources: ["Sources/**"],
          dependencies: dependencies
        )
      ]
    )
  }

  public static func shared(
    _ shared: Shared,
    destinations: Destinations = Environments.destinations,
    deploymentTargets: DeploymentTargets = Environments.deploymentTargets,
    dependencies: [TargetDependency] = []
  ) -> Project {
    .init(
      name: shared.name,
      targets: [
        .init(
          name: shared.name,
          destinations: destinations,
          product: .framework,
          bundleId: "\(Environments.partialBundleId).\(shared.name)",
          deploymentTargets: deploymentTargets,
          sources: ["Sources/**"],
          dependencies: dependencies
        )
      ]
    )
  }
}
