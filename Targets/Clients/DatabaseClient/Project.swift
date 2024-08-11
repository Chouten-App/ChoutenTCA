import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .databaseClient,
  dependencies: [
    .externalDependencies.dependenciesMacros.target,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.grdb.target,
    .shared.sharedModels.project
  ]
)
