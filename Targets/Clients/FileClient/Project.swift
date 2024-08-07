import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .fileClient,
  dependencies: [
    .externalDependencies.dependenciesMacros.target,
    .externalDependencies.composableArchitecture.target
  ]
)
