import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .home,
  dependencies: [
    .shared.architecture.project,
    .externalDependencies.kingfisher.target,
    .externalDependencies.composableArchitecture.target,
    .shared.viewComponents.project,
    .externalDependencies.shimmer.target
  ]
)
