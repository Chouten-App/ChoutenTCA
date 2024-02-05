import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .moduleClient,
  dependencies: [
    .externalDependencies.casePaths.target,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.zipFoundation.target,
    .shared.architecture.project,
    .shared.sharedModels.project
  ]
)
