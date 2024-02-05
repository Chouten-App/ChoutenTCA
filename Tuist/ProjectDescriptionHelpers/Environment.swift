//
//  Environment.swift
//  ProjectDescriptionHelpers
//
//  Created by ErrorErrorError on 2/1/24.
//
//

import ProjectDescription

public enum Environments {
  public static let appName = "Chouten"
  public static let organizationName = "chouten.app"
  public static let partialBundleId = "app.chouten"
  public static let deploymentTargets = DeploymentTargets(iOS: "15.0")
  public static let destinations: Destinations = .iOS

  public static let bundleId = "\(partialBundleId).\(appName)"
}
