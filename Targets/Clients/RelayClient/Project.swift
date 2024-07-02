import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .relayClient,
  dependencies: [
    .externalDependencies.casePaths.target,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.zipFoundation.target,
    .shared.architecture.project,
    .shared.sharedModels.project,
    .shared.viewComponents.project
  ]
)
