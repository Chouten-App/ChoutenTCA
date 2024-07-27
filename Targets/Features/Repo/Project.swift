import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .repo,
  dependencies: [
    .shared.architecture.project,
    .shared.viewComponents.project,
    .shared.sharedModels.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.repoClient.project,
    .clients.relayClient.project
  ]
)
