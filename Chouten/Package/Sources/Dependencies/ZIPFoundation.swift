//
//  File.swift
//  
//
//  Created by Inumaki on 17.10.23.
//

struct ZIPFoundation: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
    }
}
