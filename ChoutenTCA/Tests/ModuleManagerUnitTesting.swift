//
//  Tests.swift
//  Tests
//
//  Created by Inumaki on 20.08.23.
//

import XCTest
import ComposableArchitecture
@testable import ChoutenTCA


final class Tests: XCTestCase {
    @Dependency(\.moduleManager)
    var moduleManager

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_ModuleManager_importFile() {
        // TODO: check if url is still up to date
        let moduleUrl = URL(string: "https://github.com/enimax-anime/chouten-modules/raw/built/Aniwatch.to.module")
        
        // fetch module from url
        
        // import module
        
        // check if module exists
        
        // check if temporary data still exists
        
    }
    
    func test_ModuleManager_importMultipleDifferentFiles() {
        
    }
}
