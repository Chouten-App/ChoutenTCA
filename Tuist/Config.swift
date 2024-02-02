import ProjectDescription

let config = Config(
  compatibleXcodeVersions: .upToNextMajor(.init(15, 0, 0)),
  plugins: [
    .local(path: .relativeToRoot("Plugins/DependencyPlugin"))
  ]
)
