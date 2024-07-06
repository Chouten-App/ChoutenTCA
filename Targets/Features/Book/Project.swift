import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .book,
  dependencies: [
    .shared.architecture.project,
    .shared.sharedModels.project,
    .shared.viewComponents.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.dataClient.project,
    .clients.relayClient.project
  ]
)
