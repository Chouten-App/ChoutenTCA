import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.shared(
  .architecture,
  dependencies: [
    .externalDependencies.composableArchitecture.target,
    .shared.foundationHelpers.project
  ]
)
