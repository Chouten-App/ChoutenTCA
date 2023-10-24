//
//  Shimmer.swift
//
//
//  Created by Inumaki on 12.10.23.
//

struct Shimmer: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer.git", exact: "1.4.0")
    }
}
