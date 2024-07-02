import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.shared(
  .sharedModels,
  dependencies: [
    .externalDependencies.composableArchitecture.target
  ]
)
