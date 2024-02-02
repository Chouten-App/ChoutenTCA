import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .app,
  dependencies: [
    .shared.architecture.project,
    .features.more.project,
    .features.player.project,
    .features.moduleSheet.project,
    .features.discover.project,
    .shared.viewComponents.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.shimmer.target,
    .externalDependencies.kingfisher.target,
    .externalDependencies.grdb.target,
    .clients.dataClient.project
  ]
)
