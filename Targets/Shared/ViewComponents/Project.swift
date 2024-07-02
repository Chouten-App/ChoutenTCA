import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.shared(
  .viewComponents,
  dependencies: [
    .shared.sharedModels.project,
    .shared.architecture.project,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.nuke.target,
    .clients.repoClient.project
  ]
)
