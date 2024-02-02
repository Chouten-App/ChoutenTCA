import DependencyPlugin
import ProjectDescription
import ProjectDescriptionHelpers


let project = Project.feature(
  .webview,
  dependencies: [
    .shared.architecture.project,
    .externalDependencies.composableArchitecture.target,
    .clients.moduleClient.project,
    .externalDependencies.swiftSoup.target
  ]
)
