//
//  Live.swift
//
//
//  Created by Inumaki on 17.10.23.
//

import Architecture
import Combine
import Dependencies
import Foundation
import OSLog
import Semver
import SharedModels
import ZIPFoundation

extension ModuleClient: DependencyKey {
  public static let liveValue: Self = {
    let moduleFolderNames = LockIsolated([String]())
    let selectedModule = CurrentValueSubject<Module?, Never>(Module?.none)
    let moduleIds = LockIsolated([String]())
    let selectedModuleName = LockIsolated("")
    let minimumFormatVersion = 1

    let logger = Logger(subsystem: "com.inumaki.Chouten", category: "ModuleClient")

    @Sendable
    func getModules() throws -> [String] {
      if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        let directoryContents = try FileManager.default.contentsOfDirectory(
          at: documentsDirectory.appendingPathComponent("Modules"),
          includingPropertiesForKeys: nil,
          options: .skipsHiddenFiles
        )
        var directoryNames: [String] = []
        for url in directoryContents {
          var isDirectory: ObjCBool = false
          if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), isDirectory.boolValue {
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

        do {
          var decoded = try JSONDecoder().decode(Module.self, from: metadataData)
          // store icon file path
          decoded.icon = folderUrl.appendingPathComponent("icon.png").absoluteString
          return decoded
        } catch {
          print(error.localizedDescription)
        }
        return nil
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

            try moduleFolderNames.setValue(getModules())

            var moduleFound = false
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
              for trueModuleName in moduleFolderNames.value {
                let m = getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(trueModuleName))
                if let m {
                  // check if module id == m id
                  if module.id == m.id {
                    logger.log("Module exists.")
                    moduleFound = true
                    // if id matches, check version number

                    if module.version > m.version {
                      // new module version is higher, remove old module and add new one

                      // remove old dir
                      try FileManager.default.removeItem(at: modulesDirectory.appendingPathComponent(trueModuleName))

                      // copy cache module dir to modules dir
                      try fileManager.copyItem(
                        at: cacheDirectory.appendingPathComponent(moduleName),
                        to: modulesDirectory.appendingPathComponent(trueModuleName)
                      )
                    }
                  }
                }
              }
            }

            if !moduleFound {
              let trueModuleName = module.name
              try fileManager.copyItem(
                at: cacheDirectory.appendingPathComponent(moduleName),
                to: modulesDirectory.appendingPathComponent(trueModuleName)
              )
            }
          }
        }
      },
      getCurrentModule: { selectedModule.value },
      setCurrentModule: { selectedModule.send($0) },
      getModules: {
        try moduleFolderNames.setValue(getModules())
        var list: [Module] = []
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          for module in moduleFolderNames.value {
            let m = getMetadata(folderUrl: documentsDirectory.appendingPathComponent("Modules").appendingPathComponent(module))

            if let m {
              list.append(m)
              moduleIds.withValue { $0.append(.init(m.id)) }
            }
          }
        }
        return list
      },
      getMetadata: { fileUrl in
        getMetadata(folderUrl: fileUrl)
      },
      getJs: { type in
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let searchDirectory = documentsDirectory.appendingPathComponent("Modules")
            .appendingPathComponent(selectedModuleName.value)
            .appendingPathComponent(type.capitalized)
          let jsData = try Data(contentsOf: searchDirectory.appendingPathComponent("code.js"))
          let jsString = String(data: jsData, encoding: .utf8)
          return jsString
        }
        return nil
      },
      deleteModule: { module in
        if let index = moduleIds.value.firstIndex(of: .init(module.id)) {
          do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

            try FileManager.default
                  .removeItem(
                    at: documentsDirectory
                        .appendingPathComponent("Modules")
                        .appendingPathComponent(moduleFolderNames[index])
                  )
            // let globalIndex = globalData.getAvailableModules().firstIndex(of: module)
            // if globalIndex != nil {
            //    var temp = globalData.getAvailableModules()
            //    temp.remove(at: globalIndex!)
            //    globalData.setAvailableModules(temp)
            // }
            //
            return true
          } catch {
            logger.error("\(error.localizedDescription)")
          }
        }
        return false
      },
      setSelectedModuleName: { module in
        let index = moduleIds.value.firstIndex(of: .init(module.id))
        if let index, moduleFolderNames.count > index {
          selectedModuleName.setValue(moduleFolderNames[index])
        }
      },
      currentModuleStream: { selectedModule.values.eraseToStream() }
    )
  }()
}
