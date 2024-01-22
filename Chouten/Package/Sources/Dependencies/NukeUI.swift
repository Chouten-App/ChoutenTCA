//
//  File.swift
//  
//
//  Created by Inumaki on 17.12.23.
//

struct NukeUI: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/kean/Nuke.git", from: "12.2.0")
    }
}
