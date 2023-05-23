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
    var importFromFile: (_ fileUrl: URL) -> Void
    var getModules: () -> Void
    var getMetadata: (_ folderUrl: URL) -> Module?
    var getJsCount: (_ type: String) -> Int
    var getJsForType: (_ type: String, _ num: Int) -> ReturnedData?
    
    struct Failure: Error {}
}

extension ModuleManager {
    static var moduleFolderNames: [String] = []
    static var moduleIds: [String] = []
    static var selectedModuleName: String = ""
    
    static private var internalClass = ModuleManagerInternal()
    
    static let live = Self(
        importFromFile: { fileUrl in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileManager = FileManager.default
                
                // Create a new directory for the unzipped files
                let unzipDirectoryURL = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(fileUrl.lastPathComponent.components(separatedBy: ".")[0])
                do {
                    // Unzip the file using the ZIPFoundation library
                    let tempDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent("TEMPORARY")
                    try FileManager.default.unzipItem(at: fileUrl, to: tempDirectory)
                    
                    // check if id already exists in the apps directory
                    let tempData = internalClass.getMetadata(folderUrl: tempDirectory)
                    if tempData != nil {
                        print(moduleFolderNames)
                        if moduleFolderNames.count > 0 {
                            for moduleFolder in moduleFolderNames {
                                let data = internalClass.getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolder))
                                if data != nil {
                                    if tempData!.id == data!.id {
                                        // module already exists, check versions
                                        let ver = tempData!.version.versionCompare(data!.version)
                                        
                                        switch ver {
                                        case .orderedAscending:
                                            // installed version is higher
                                            try fileManager.removeItem(at: tempDirectory)
                                        case .orderedSame:
                                            // installed version is the same
                                            try fileManager.removeItem(at: tempDirectory)
                                        case .orderedDescending:
                                            // installed version is lower
                                            try fileManager.removeItem(at: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolder))
                                            
                                            try fileManager.copyItem(at: tempDirectory, to: unzipDirectoryURL)
                                            
                                            try fileManager.removeItem(at: tempDirectory)
                                        }
                                    }
                                }
                            }
                        } else {
                            print(unzipDirectoryURL)
                            try fileManager.copyItem(at: tempDirectory, to: unzipDirectoryURL)
                            
                            try fileManager.removeItem(at: tempDirectory)
                        }
                    }
                    
                    try FileManager.default.removeItem(at: fileUrl)
                    
                    // update globalData incase the app is already open
                    
                    moduleFolderNames = internalClass.getModules()
                    moduleIds = []
                    //globalData.availableModules = []
                    
                    for moduleFolder in moduleFolderNames {
                        let data = internalClass.getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolder))
                        
                        if data != nil {
                            //globalData.availableModules.append(data!)
                            moduleIds.append(data!.id)
                        }
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                    let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                    NotificationCenter.default
                        .post(
                            name: NSNotification.Name("floaty"),
                            object: nil,
                            userInfo: data
                        )
                }
            }
        },
        getModules: {
            moduleFolderNames = internalClass.getModules()
        }, getMetadata: { fileUrl in
            return internalClass.getMetadata(folderUrl: fileUrl)
        }, getJsCount: { type in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let infoDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(selectedModuleName).appendingPathComponent(type.capitalized)
                do {
                    let fileUrls = try FileManager.default.contentsOfDirectory(at: infoDirectory, includingPropertiesForKeys: nil)
                    let jsFileUrls = fileUrls.filter { $0.pathExtension == "js" }
                    return jsFileUrls.count
                } catch {
                    print("Error while enumerating files: \(error.localizedDescription)")
                    let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                    NotificationCenter.default
                        .post(
                            name: NSNotification.Name("floaty"),
                            object: nil,
                            userInfo: data
                        )
                    return 0
                }
            }
            return 0
        }, getJsForType:  { type, num in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                do {
                    let searchDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(selectedModuleName).appendingPathComponent(type.capitalized)
                    let jsData = try Data(contentsOf: searchDirectory.appendingPathComponent(num == 0 ? "code.js" : "code\(num).js"))
                    let jsString = String(data: jsData, encoding: .utf8)
                    
                    // split js into logic and vars
                    let vars = jsString?.components(separatedBy: "function logic() {")[0]
                    var logic = jsString?.components(separatedBy: "function logic() {")[1].trimmingCharacters(in: .whitespaces)
                    if logic != nil {
                        logic = """
                        try {
                        function logic() {
                            \(logic!)
                        logic()
                        } catch (error) {
                            const stacktrace = error.stack;
                            const linesTemp = stacktrace.split("\\nglobal")[0];
                            const lines = linesTemp.replace("logic@user-script:", "");
                            console.error(`Uncaught ${error.name}: ${error.message}-----${lines}`);
                        }
                        """
                    }
                    let context = JSContext()

                    let data: JSValue? = context?.evaluateScript(vars)
                    
                    if data != nil && data!.isString {
                        let string = data!.toString()
                        if string != nil {
                            let temp = string!.data(using: .utf8)
                            if temp != nil {
                                do {
                                    var stringReturn = try JSONDecoder().decode(StringReturn.self, from: temp!)
                                    
                                    let returnValue = ReturnedData(
                                        request: stringReturn.request,
                                        usesApi: stringReturn.usesApi,
                                        allowExternalScripts: stringReturn.allowExternalScripts,
                                        removeScripts: stringReturn.removeScripts,
                                        imports: stringReturn.imports,
                                        js: logic!
                                    )
                                    return returnValue
                                } catch let error {
                                    print(error.localizedDescription)
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
                    }
                } catch {
                    print("Error loading metadata: \(error)")
                    let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                    NotificationCenter.default
                        .post(
                            name: NSNotification.Name("floaty"),
                            object: nil,
                            userInfo: data
                        )
                }
            }
            return nil
        }
    )
    
    static let test = Self(
        importFromFile: { fileUrl in
            
        },
        getModules: {
            
        }, getMetadata: { fileUrl in
            return nil
        },getJsCount: { type in
            return 0
        }, getJsForType:  { type, num in
            return nil
        }
    )
}

class ModuleManagerInternal {
    func getModules() -> [String] {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory.appendingPathComponent("Modules"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                var directoryNames: [String] = []
                for url in directoryContents {
                    var isDirectory: ObjCBool = false
                    if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                        directoryNames.append(url.lastPathComponent)
                    }
                }
                return directoryNames
            } catch {
                print("Error getting directory contents: \(error.localizedDescription)")
                let data = ["data": FloatyData(message: "\(error)", error: true, action: nil)]
                NotificationCenter.default
                    .post(
                        name: NSNotification.Name("floaty"),
                        object: nil,
                        userInfo: data
                    )
            }
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
