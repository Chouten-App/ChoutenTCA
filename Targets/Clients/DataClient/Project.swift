import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .dataClient,
  dependencies: [
    .externalDependencies.composableArchitecture.target,
    .shared.architecture.project,
    .shared.sharedModels.project
  ]
)
