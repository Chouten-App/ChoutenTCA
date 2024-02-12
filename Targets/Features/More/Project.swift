import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .more,
  dependencies: [
    .clients.buildClient.project,
    .shared.architecture.project,
    .externalDependencies.composableArchitecture.target,
    .features.appearance.project,
    .externalDependencies.nukeUI.target
  ]
)
