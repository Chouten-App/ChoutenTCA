import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .home,
  dependencies: [
    .shared.architecture.project,
    .shared.viewComponents.project,
    .shared.sharedModels.project,
    .externalDependencies.composableArchitecture.target,
  ]
)
