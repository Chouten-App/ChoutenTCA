import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .repo,
  dependencies: [
    .shared.architecture.project,
    .externalDependencies.kingfisher.target,
    .externalDependencies.composableArchitecture.target,
    .shared.viewComponents.project,
    .externalDependencies.shimmer.target,
    .externalDependencies.nukeUI.target,
    .shared.sharedModels.project,
    .clients.moduleClient.project
  ]
)
