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
        // URL for the module file (update with correct URL)
        guard let moduleUrl = URL(string: "https://github.com/enimax-anime/chouten-modules/raw/built/Aniwatch.to.module") else {
            XCTFail("Invalid module URL")
            return
        }
        
        // Fetch module data from URL
        let expectation = XCTestExpectation(description: "Fetch module data from URL")
        var moduleData: Data?
        URLSession.shared.dataTask(with: moduleUrl) { data, response, error in
            moduleData = data
            expectation.fulfill()
        }.resume()
        
        // Wait for the data task to complete
        wait(for: [expectation], timeout: 10.0)
        
        // TODO: Implement the logic to import the module from the fetched data
        // Get the documents directory URL
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            XCTFail("Unable to access documents directory")
            return
        }
        
        // Create a Modules directory within the documents directory
        let modulesDirectory = documentsDirectory.appendingPathComponent("Modules", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: modulesDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("Failed to create Modules directory: \(error)")
            return
        }
        
        // Save the downloaded module data to the Modules directory
        let moduleFileUrl = modulesDirectory.appendingPathComponent("Aniwatch.to.module")
        do {
            try moduleData?.write(to: moduleFileUrl)
        } catch {
            XCTFail("Failed to save module data: \(error)")
            return
        }
        
        do {
            try moduleManager.importFromFile(moduleFileUrl)
        } catch {
            XCTFail("Failed to import module")
            return
        }
    }
    
    func test_ModuleManager_importMultipleDifferentFiles() {
        
    }
}
