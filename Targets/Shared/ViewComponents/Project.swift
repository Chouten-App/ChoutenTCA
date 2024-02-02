import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.shared(
  .viewComponents,
  dependencies: [
    .externalDependencies.grdb.target,
    .shared.sharedModels.project,
    .externalDependencies.composableArchitecture.target
  ]
)
