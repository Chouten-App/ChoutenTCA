import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
    .repoClient,
  dependencies: [
    .externalDependencies.dependenciesMacros.target,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.semver.target,
    .externalDependencies.tagged.target,
    .shared.sharedModels.project,
    .shared.architecture.project
  ]
)
