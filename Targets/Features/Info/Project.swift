import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .info,
  dependencies: [
    .features.video.project,
    .features.book.project,
    .shared.architecture.project,
    .shared.viewComponents.project,
    .shared.sharedModels.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.relayClient.project
  ]
)
