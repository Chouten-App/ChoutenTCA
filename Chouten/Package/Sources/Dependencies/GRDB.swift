//
//  File.swift
//  
//
//  Created by Inumaki on 24.12.23.
//

struct GRDB: PackageDependency {
    var dependency: Package.Dependency {
        .package(url: "https://github.com/Eltik/GRDB.git", exact: "6.21.6")
    }
}
