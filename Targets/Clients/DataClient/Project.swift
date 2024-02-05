import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .dataClient,
  dependencies: [
    .externalDependencies.dependenciesMacros.target,
    .externalDependencies.composableArchitecture.target,
    .shared.architecture.project,
    .shared.sharedModels.project
  ]
)
