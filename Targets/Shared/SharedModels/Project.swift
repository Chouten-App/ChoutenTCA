import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.shared(
  .sharedModels,
  dependencies: [
    .externalDependencies.grdb.target,
    .externalDependencies.composableArchitecture.target
  ]
)
