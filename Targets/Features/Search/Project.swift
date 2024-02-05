import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .search,
  dependencies: [
    .shared.architecture.project,
    .shared.viewComponents.project,
    .externalDependencies.shimmer.target,
    .features.info.project,
    .externalDependencies.kingfisher.target,
    .externalDependencies.composableArchitecture.target,
    .shared.sharedModels.project,
    .clients.moduleClient.project,
    .features.webview.project,
    .externalDependencies.ascollectionView.target,
    .externalDependencies.nukeUI.target
  ]
)
