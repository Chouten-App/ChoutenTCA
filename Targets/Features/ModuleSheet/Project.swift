import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.feature(
  .moduleSheet,
  dependencies: [
    .shared.architecture.project,
    .clients.moduleClient.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.kingfisher.target
  ]
)
