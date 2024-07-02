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
  public static let partialBundleId = "com.inumaki"
  public static let bundleId = "\(partialBundleId).\(appName)"

  public static let iosDeploymentTarget = DeploymentTargets.iOS("15.0")
  public static let iosDestination: Destinations = .iOS

  public static let deploymentTargets: DeploymentTargets = iosDeploymentTarget
  public static var destinations: Destinations = iosDestination
}
