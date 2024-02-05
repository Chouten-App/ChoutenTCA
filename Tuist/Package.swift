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
    .package(url: "https://github.com/apptekstudios/ASCollectionView", exact: "2.1.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.7.2"),
    .package(url: "https://github.com/groue/GRDB.swift", exact: "6.24.2"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", exact: "7.0.0"),
    .package(url: "https://github.com/kean/Nuke.git", exact: "12.2.0"),
    .package(url: "https://github.com/scinfu/SwiftSoup.git", exact: "2.6.1"),
    .package(url: "https://github.com/markiv/SwiftUI-Shimmer.git", exact: "1.4.0"),
    .package(url: "https://github.com/Suwatte/Texture.git", exact: "3.1.1"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", exact: "0.9.18")
  ]
)
