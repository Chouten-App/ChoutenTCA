//
//  File.swift
//  
//
//  Created by Inumaki on 10.10.23.
//

import PackageDescription

struct ChoutenPlatforms: PlatformSet {
    var body: any SupportedPlatforms {
        SupportedPlatform.iOS(.v15)
    }
}
