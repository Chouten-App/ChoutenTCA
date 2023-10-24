//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

struct ComposableArchitecture: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.2.0")
    }
}
