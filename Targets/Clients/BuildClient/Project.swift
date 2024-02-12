import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.client(
  .buildClient,
  dependencies: [
    .externalDependencies.dependenciesMacros.target,
    .externalDependencies.composableArchitecture.target,
    .externalDependencies.semver.target,
    .externalDependencies.tagged.target
  ]
)
