//
//  Package.swift
//  ProjectDescriptionHelpers
//
//  Created by ErrorErrorError on 1/30/24.
//
//

import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: Environments.appName,
  organizationName: Environments.organizationName,
  targets: [
    .init(
      name: Environments.appName,
      destinations: .iOS,
      product: .app,
      bundleId: Environments.bundleId,
      deploymentTargets: .iOS("15.0"),
      infoPlist: .file(path: "Resources/ChoutenApp-Info.plist"),
      sources: ["Sources/**"],
      resources: [.folderReference(path: "../Shared/Resources/**")],
      entitlements: .file(path: "Resources/ChoutenApp.entitlements"),
      dependencies: [
        .externalDependencies.composableArchitecture.target,
        .features.app.project,
      ],
      settings: .settings(base: ["GENERATE_INFOPLIST_FILE": true])
    )
  ]
)
