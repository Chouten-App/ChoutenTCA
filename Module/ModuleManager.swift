//
//  APIClient.swift
//  ChoutenTCA
//
//  Created by Inumaki on 24.04.23.
//

import Foundation
import ComposableArchitecture
import ZIPFoundation
import JavaScriptCore
import SwiftyJSON

private enum ModuleManagerKey: DependencyKey {
    static let liveValue = ModuleManager.live
}
private enum ModuleManagerTestKey: DependencyKey {
    static let liveValue = ModuleManager.test
}
extension DependencyValues {
    var moduleManager: ModuleManager {
        get { self[ModuleManagerKey.self] }
        set { self[ModuleManagerKey.self] = newValue }
    }
    
    var testModuleManager: ModuleManager {
        get { self[ModuleManagerTestKey.self] }
        set { self[ModuleManagerTestKey.self] = newValue }
    }
}

struct ModuleManager {
    var importFromFile: (_ fileUrl: URL) throws -> Void
    var getModules: () throws -> [Module]
    var getMetadata: (_ folderUrl: URL) -> Module?
    var getJsCount: (_ type: String) throws -> Int
    var getJsForType: (_ type: String, _ num: Int) throws -> String?
    var deleteModule: (_ module: Module) throws -> Bool
    var setSelectedModuleName: (_ module: Module) -> Void
    var validateModules: () throws -> [Module]
    
    // data fetchers
    var search: (_ query: String) throws -> Decodable
    
    struct Failure: Error {}
}

extension ModuleManager {
    static var moduleFolderNames: [String] = []
    static var moduleIds: [String] = []
    static var selectedModuleName: String = ""
    static let minimumFormatVersion: Int = 1
    
    static private var internalClass = ModuleManagerInternal()
    
    @Dependency(\.globalData)
    static var globalData
    
    
    static let live = Self(
        importFromFile: { fileUrl in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileManager = FileManager.default
                
                // Create cache directory if it doesnt exist
                let cacheDirectory = documentsDirectory.appendingPathComponent("CACHE")
                let modulesDirectory = documentsDirectory.appendingPathComponent("Modules")
                
                if !fileManager.fileExists(atPath: cacheDirectory.absoluteString) {
                    do {
                        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                        print("Directory created at path: \(cacheDirectory)")
                    } catch {
                        print("Error creating directory: \(error)")
                    }
                } else {
                    print("Directory already exists at path: \(cacheDirectory)")
                }
                
                var moduleCount = 0
                do {
                    // Get the contents of the directory
                    let moduleArray = try internalClass.getModules()
                    
                    // Return the count of directories
                    moduleCount = moduleArray.count
                } catch {
                    print("Error counting folders: \(error)")
                    moduleCount = 0
                }
                
                let moduleName = "Module \(moduleCount)"
                print("Module Name: \(moduleName)")
                
                do {
                    try FileManager.default.unzipItem(at: fileUrl, to: cacheDirectory.appendingPathComponent(moduleName))
                    print("Unzip successful.")
                } catch {
                    print(error.localizedDescription)
                }
                
                let module = internalClass.getMetadata(folderUrl: cacheDirectory.appendingPathComponent(moduleName))
                
                if let module {
                    print("Module metadata parsing successful.")
                    
                    moduleFolderNames = try internalClass.getModules()
                    
                    var moduleFound = false
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        for trueModuleName in moduleFolderNames {
                            let m = internalClass.getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(trueModuleName))
                            if let m = m {
                                // check if module id == m id
                                if module.id == m.id {
                                    print("Module exists.")
                                    moduleFound = true
                                    // if id matches, check version number
                                    let versionResult = module.version.versionCompare(m.version)
                                    
                                    switch versionResult {
                                    case .orderedSame:
                                        // versions are the same, do nothing to modules dir
                                        break
                                    case .orderedAscending:
                                        // new module version is lower, do nothing to module dir
                                        break
                                    case .orderedDescending:
                                        // new module version is higher, remove old module and add new one
                                        
                                        // remove old dir
                                        try FileManager.default.removeItem(at: modulesDirectory.appendingPathComponent(trueModuleName))
                                        
                                        // copy cache module dir to modules dir
                                        try fileManager.copyItem(at: cacheDirectory.appendingPathComponent(moduleName), to: modulesDirectory.appendingPathComponent(trueModuleName))
                                        
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    if !moduleFound {
                        let trueModuleName = module.name
                        try fileManager.copyItem(at: cacheDirectory.appendingPathComponent(moduleName), to: modulesDirectory.appendingPathComponent(trueModuleName))
                    }
                }
            }
        },
        getModules: {
            moduleFolderNames = try internalClass.getModules()
            var list: [Module] = []
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                for module in moduleFolderNames {
                    let m = internalClass.getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(module))
                    if m != nil {
                        list.append(m!)
                        moduleIds.append(m!.id)
                    }
                }
            }
            return list
        },
        getMetadata: { fileUrl in
            return internalClass.getMetadata(folderUrl: fileUrl)
        },
        getJsCount: { type in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let infoDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(selectedModuleName).appendingPathComponent(type.capitalized)
                let fileUrls = try FileManager.default.contentsOfDirectory(at: infoDirectory, includingPropertiesForKeys: nil)
                let jsFileUrls = fileUrls.filter { $0.pathExtension == "js" }
                return jsFileUrls.count
            }
            return 0
        },
        getJsForType: { type, num in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let searchDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(selectedModuleName).appendingPathComponent(type.capitalized)
                print("GETING JS")
                let jsData = try Data(contentsOf: searchDirectory.appendingPathComponent("code.js"))
                let jsString = String(data: jsData, encoding: .utf8)
                return jsString
            }
            return nil
        },
        deleteModule: { module in
            let index = moduleIds.firstIndex(of: module.id)
            if index != nil {
                do {
                    let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    // Check if file exists
                    print(documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolderNames[index!]).absoluteString)
                    
                    try FileManager.default.removeItem(at: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolderNames[index!]))
                    let globalIndex = globalData.getAvailableModules().firstIndex(of: module)
                    if globalIndex != nil {
                        var temp = globalData.getAvailableModules()
                        temp.remove(at: globalIndex!)
                        globalData.setAvailableModules(temp)
                    }
                    return true
                } catch let error {
                    print(error)
                    let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                    NotificationCenter.default
                        .post(name:           NSNotification.Name("floaty"),
                              object: nil, userInfo: data)
                }
            }
            return false
        },
        setSelectedModuleName: { module in
            let index = moduleIds.firstIndex(of: module.id)
            if let index = index, moduleFolderNames.count > index {
                selectedModuleName = moduleFolderNames[index]
            }
        },
        validateModules: {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let modulesDir = documentsDirectory.appendingPathComponent("Modules")
                
                // check if any .module files still exist
                let modulesDirContents = try FileManager.default.contentsOfDirectory(
                    at: modulesDir,
                    includingPropertiesForKeys: nil
                )
                for url in modulesDirContents {
                    if url.lastPathComponent.contains(".module") {
                        try FileManager.default.removeItem(at: url)
                    } else if url.lastPathComponent == "TEMPORARY" {
                        // remove temporary folder
                        try FileManager.default.removeItem(at: url)
                    }
                }
                
                // read all modules in Modules folder
                moduleFolderNames = try internalClass.getModules()
                var list: [Module] = []
                for module in moduleFolderNames {
                    let m = internalClass.getMetadata(folderUrl: modulesDir.appendingPathComponent(module))
                    if let m = m {
                        // check format version
                        if m.formatVersion >= minimumFormatVersion {
                            list.append(m)
                        }
                    }
                }
                // return all modules that pass
                return list
            }
            throw "Documents folder unavailable"
        },
        search: { query in
            print(query)
            return DecodableResult(result: "", nextUrl: nil)
        }
    )
    
    static let test = Self(
        importFromFile: { fileUrl in
            
        },
        getModules: {
            return []
        }, getMetadata: { fileUrl in
            return nil
        }, getJsCount: { type in
            return 0
        }, getJsForType: { type, num in
            return nil
        },
        deleteModule: { _ in
            return false
        },
        setSelectedModuleName: { module in
            
        }, validateModules: {
            return []
        }, search: { query in
            print(query)
            return DecodableResult(result: "", nextUrl: nil)
        }
    )
}

class ModuleManagerInternal {
    func getModules() throws -> [String] {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory.appendingPathComponent("Modules"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            var directoryNames: [String] = []
            for url in directoryContents {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    directoryNames.append(url.lastPathComponent)
                }
            }
            return directoryNames
        }
        return []
    }
    
    func getMetadata(folderUrl: URL) -> Module? {
        do {
            let metadataData = try Data(contentsOf: folderUrl.appendingPathComponent("metadata.json"))
            var decoded = try JSONDecoder().decode(Module.self, from: metadataData)

            // store icon file path
            decoded.icon = folderUrl.appendingPathComponent("icon.png").absoluteString
            return decoded
        } catch {
            print("Error loading metadata: \(error)")
            let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
            NotificationCenter.default
                .post(
                    name: NSNotification.Name("floaty"),
                    object: nil,
                    userInfo: data
                )
            return nil
        }
    }
}
