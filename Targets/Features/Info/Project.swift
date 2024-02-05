import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .info,
  dependencies: [
    .shared.architecture.project,
    .externalDependencies.kingfisher.target,
    .externalDependencies.composableArchitecture.target,
    .shared.viewComponents.project,
    .features.webview.project,
    .externalDependencies.shimmer.target,
    .clients.dataClient.project,
    .externalDependencies.nukeUI.target
  ]
)
