//
//  File.swift
//
//
//  Created by Inumaki on 17.10.23.
//

import Foundation
import OSLog
import Dependencies
import ZIPFoundation
import Architecture

extension ModuleClient: DependencyKey {
    public static let liveValue: Self = {
        let logger = Logger(subsystem: "com.inumaki.Chouten", category: "ModuleClient")
        
        @Sendable
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
        
        @Sendable
        func getMetadata(folderUrl: URL) -> Module? {
            do {
                let metadataData = try Data(contentsOf: folderUrl.appendingPathComponent("metadata.json"))
                var decoded = try JSONDecoder().decode(Module.self, from: metadataData)
                
                // store icon file path
                decoded.icon = folderUrl.appendingPathComponent("icon.png").absoluteString
                return decoded
            } catch {
                logger.error("Error loading metadata: \(error)")
                return nil
            }
        }
        
        return Self(
            importFromFile: { fileUrl in
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileManager = FileManager.default
                    
                    // Create cache directory if it doesnt exist
                    let cacheDirectory = documentsDirectory.appendingPathComponent("CACHE")
                    let modulesDirectory = documentsDirectory.appendingPathComponent("Modules")
                    
                    if !fileManager.fileExists(atPath: cacheDirectory.absoluteString) {
                        do {
                            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                            
                            logger.log("Directory created at path: \(cacheDirectory)")
                        } catch {
                            logger.error("Error creating directory: \(error)")
                        }
                    } else {
                        logger.warning("Directory already exists at path: \(cacheDirectory)")
                    }
                    
                    var moduleCount = 0
                    do {
                        // Get the contents of the directory
                        let moduleArray = try getModules()
                        
                        // Return the count of directories
                        moduleCount = moduleArray.count
                    } catch {
                        logger.error("Error counting folders: \(error)")
                        moduleCount = 0
                    }
                    
                    let moduleName = "Module \(moduleCount)"
                    logger.log("Module Name: \(moduleName)")
                    
                    do {
                        try FileManager.default.unzipItem(at: fileUrl, to: cacheDirectory.appendingPathComponent(moduleName))
                        logger.log("Unzip successful.")
                    } catch {
                        logger.error("\(error.localizedDescription)")
                    }
                    
                    let module = getMetadata(folderUrl: cacheDirectory.appendingPathComponent(moduleName))
                    
                    if let module {
                        logger.log("Module metadata parsing successful.")
                        
                        moduleFolderNames = try getModules()
                        
                        var moduleFound = false
                        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                            for trueModuleName in moduleFolderNames {
                                let m = getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(trueModuleName))
                                if let m = m {
                                    // check if module id == m id
                                    if module.id == m.id {
                                        logger.log("Module exists.")
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
                moduleFolderNames = try getModules()
                var list: [Module] = []
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    for module in moduleFolderNames {
                        let m = getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(module))
                        if m != nil {
                            list.append(m!)
                            moduleIds.append(m!.id)
                        }
                    }
                }
                return list
            },
            getMetadata: { fileUrl in
                return getMetadata(folderUrl: fileUrl)
            },
            getJs: { type in
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let searchDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(selectedModuleName).appendingPathComponent(type.capitalized)
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
                        
                        try FileManager.default.removeItem(at: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolderNames[index!]))
                        /*
                        let globalIndex = globalData.getAvailableModules().firstIndex(of: module)
                        if globalIndex != nil {
                            var temp = globalData.getAvailableModules()
                            temp.remove(at: globalIndex!)
                            globalData.setAvailableModules(temp)
                        }
                         */
                        return true
                    } catch {
                        logger.error("\(error.localizedDescription)")
                    }
                }
                return false
            },
            setSelectedModuleName: { module in
                let index = moduleIds.firstIndex(of: module.id)
                if let index = index, moduleFolderNames.count > index {
                    selectedModuleName = moduleFolderNames[index]
                }
            }
        )
    }()
}
