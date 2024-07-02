// swift-tools-version: 5.9

import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(
  productTypes: [:],
  platforms: [.iOS]
)
#endif

let package = Package(
  name: "PackageName",
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.11.2"),
    .package(url: "https://github.com/kean/Nuke.git", exact: "12.5.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", exact: "2.6.1"),
    .package(url: "https://github.com/Suwatte/Texture.git", exact: "3.1.1"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.18"),
    .package(url: "https://github.com/kutchie-pelaez/Semver.git", exact: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged.git", exact: "0.10.0"),
  ]
)
