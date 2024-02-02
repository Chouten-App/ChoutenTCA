import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .discover,
  dependencies: [
    .shared.architecture.project,
    .shared.viewComponents.project,
    .externalDependencies.shimmer.target,
    .features.search.project,
    .externalDependencies.kingfisher.target,
    .externalDependencies.composableArchitecture.target,
    .clients.moduleClient.project
  ]
)
