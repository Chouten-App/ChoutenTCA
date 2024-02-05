import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.shared(
  .architecture,
  dependencies: [
    .externalDependencies.casePaths.target,
    .externalDependencies.composableArchitecture.target,
    .shared.foundationHelpers.project
  ]
)
