import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .player,
  dependencies: [
    .shared.architecture.project,
    .externalDependencies.composableArchitecture.target,
    .shared.viewComponents.project,
    .externalDependencies.kingfisher.target,
    .features.webview.project,
    .shared.sharedModels.project,
    .clients.moduleClient.project,
    .clients.dataClient.project,
    .externalDependencies.grdb.target
  ]
)
