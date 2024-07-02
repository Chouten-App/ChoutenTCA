//
//  Project.swift
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
    .target(
      name: Environments.appName,
      destinations: Environments.iosDestination,
      product: .app,
      bundleId: Environments.bundleId,
      deploymentTargets: Environments.iosDeploymentTarget,
      infoPlist: .file(path: "Resources/ChoutenApp-Info.plist"),
      sources: ["Sources/**"],
      resources: [
        "../Shared/Resources/**",
        "./Resources/LaunchScreen.storyboard"
      ],
      entitlements: .file(path: "Resources/ChoutenApp.entitlements"),
      scripts: [.swiftLint, .swiftFormat],
      dependencies: [
        .externalDependencies.composableArchitecture.target,
        .features.app.project
      ],
      settings: .settings(base: [
          "GENERATE_INFOPLIST_FILE": true,
          "CURRENT_PROJECT_VERSION": "1",
          "MARKETING_VERSION": "0.4.0",
          "DEVELOPMENT_TEAM": "A9QQBWPHB7"
      ])
    )
  ]
)
