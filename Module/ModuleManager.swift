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
    var getJsForType: (_ type: String, _ num: Int) throws -> ReturnedData?
    var deleteModule: (_ module: Module) throws -> Bool
    var setSelectedModuleName: (_ module: Module) -> Void
    
    // data fetchers
    var search: (_ query: String) throws -> Decodable
    
    struct Failure: Error {}
}

extension ModuleManager {
    static var moduleFolderNames: [String] = []
    static var moduleIds: [String] = []
    static var selectedModuleName: String = ""
    
    static private var internalClass = ModuleManagerInternal()
    
    @Dependency(\.globalData)
    static var globalData
    
    static let live = Self(
        importFromFile: { fileUrl in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileManager = FileManager.default
                
                // Create a new directory for the unzipped files
                let unzipDirectoryURL = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(fileUrl.lastPathComponent.components(separatedBy: ".")[0])
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
                                        break
                                    case .orderedSame:
                                        // installed version is the same
                                        break
                                    case .orderedDescending:
                                        // installed version is lower
                                        try fileManager.removeItem(at: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolder))
                                        
                                        try fileManager.copyItem(at: tempDirectory, to: unzipDirectoryURL)
                                    }
                                    
                                    try fileManager.removeItem(at: tempDirectory)
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
                
                moduleFolderNames = try internalClass.getModules()
                moduleIds = []
                globalData.setAvailableModules([])
                
                
                for moduleFolder in moduleFolderNames {
                    let data = internalClass.getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(moduleFolder))
                    
                    if let data {
                        globalData.appendAvailableModules(data)
                        moduleIds.append(data.id)
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
        getJsForType:  { type, num in
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let searchDirectory = documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(selectedModuleName).appendingPathComponent(type.capitalized)
                print("GETING JS")
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
                
                print(vars)

                let data: JSValue? = context?.evaluateScript((vars ?? "") + "requestData()")
                
                print(data)
                
                if data != nil && data!.isString {
                    let string = data!.toString()
                    if string != nil {
                        if let dataFromString = string!.data(using: .utf8, allowLossyConversion: false) {
                            let json = try JSON(data: dataFromString)
                            
                            let request = Request(url: json["request"]["url"].string ?? "", method: json["request"]["method"].string ?? "", headers: [], body: nil)
                            let returnValue = ReturnedData(
                                request: request,
                                usesApi: json["usesApi"].bool ?? false,
                                allowExternalScripts: json["allowExternalScripts"].bool ?? false,
                                removeScripts: json["removeScripts"].bool ?? true,
                                imports: json["imports"].array as? [String] ?? [],
                                js: logic!
                            )
                            return returnValue
                        }
                    }
                }
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
            if index != nil {
                selectedModuleName = moduleFolderNames[index!]
            }
        }, search: { query in
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
