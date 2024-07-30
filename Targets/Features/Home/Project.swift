import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

/*
let project = Project.feature(
  .home,
  dependencies: [
    .shared.architecture.project,
    .shared.viewComponents.project,
    .shared.sharedModels.project,
    .externalDependencies.composableArchitecture.target
  ]
)
 */

let project = Project.feature(
  .home,
  dependencies: [
    .shared.architecture.project,
    .externalDependencies.composableArchitecture.target,
    .shared.sharedModels.project,
    .clients.databaseClient.project
  ]
)
