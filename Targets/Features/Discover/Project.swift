import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .discover,
  dependencies: [
    .features.info.project,
    .shared.architecture.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.dataClient.project,
    .clients.relayClient.project
  ]
)
