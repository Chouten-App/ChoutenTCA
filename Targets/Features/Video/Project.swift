import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .video,
  dependencies: [
    .shared.architecture.project,
    .shared.viewComponents.project,
    .shared.sharedModels.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.relayClient.project
  ]
)
