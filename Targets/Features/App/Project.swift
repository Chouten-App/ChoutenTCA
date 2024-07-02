import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.feature(
  .app,
  dependencies: [
    .features.home.project,
    .features.search.project,
    .features.discover.project,
    .features.repo.project,
    .features.settings.project,
    .shared.architecture.project,
    .shared.viewComponents.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.dataClient.project,
    .clients.repoClient.project
  ]
)
