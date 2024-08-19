//
//  Live.swift
//  
//
//  Created by Inumaki on 14.06.24.
//

import Architecture
import Combine
import Dependencies
import Foundation
import OSLog
import SharedModels
import ZIPFoundation

extension RepoClient: DependencyKey {
    public static let liveValue: Self = {
        let logger = Logger(subsystem: "com.inumaki.Chouten", category: "RepoClient")

        @Sendable func _getRepos() throws -> [RepoMetadata] {
            let fileManager = FileManager.default

            // Get the path to the user's Documents directory
            guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("Could not locate the Documents directory.")
                return []
            }

            // Append the "Repos" folder to the path
            let reposDirectory = documentsDirectory.appendingPathComponent("Repos")

            do {
                // Get the list of all items in the "Repos" directory
                let items = try fileManager.contentsOfDirectory(at: reposDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

                var repoArray: [RepoMetadata] = []
                for item in items {
                    var isDirectory: ObjCBool = false

                    // Check if the item is a directory
                    if fileManager.fileExists(atPath: item.path, isDirectory: &isDirectory), isDirectory.boolValue {
                        // Construct the path to the "metadata.json" file
                        let metadataFilePath = item.appendingPathComponent("metadata.json")

                        if fileManager.fileExists(atPath: metadataFilePath.path) {
                            do {
                                // Read the contents of the "metadata.json" file
                                let jsonData = try Data(contentsOf: metadataFilePath)

                                // Convert the JSON data to a string for printing
                                let repo = try JSONDecoder().decode(RepoMetadata.self, from: jsonData)

                                repoArray.append(repo)
                                print("Loaded Repo \(repo.id)")
                            } catch {
                                print("Failed to read JSON file at path: \(metadataFilePath.path), error: \(error)")
                            }
                        } else {
                            print("No metadata.json file found in directory: \(item.path)")
                        }
                    }
                }
                return repoArray
            } catch {
                print("Failed to list contents of directory: \(reposDirectory.path), error: \(error)")
            }

            return []
        }

        return RepoClient(
            fetchRepoDetails: { url in
                // check if metadata.json exists
                let metadataUrl = url.appendingPathComponent("metadata.json")

                let (data, response) = try await URLSession.shared.data(from: metadataUrl)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    return nil
                }

                do {
                    var repoMetadata = try JSONDecoder().decode(RepoMetadata.self, from: data)

                    repoMetadata.url = url.absoluteString

                    return repoMetadata
                } catch {
                    logger.log("JSON Error: \(error.localizedDescription)")
                    return nil
                }
            },
            installRepo: { url in
                print("Installing repository with URL \(url)...")
                let metadataUrl = url.appendingPathComponent("metadata.json")

                let (data, response) = try await URLSession.shared.data(from: metadataUrl)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    return
                }
                
                print("Successfully fetched repository data. Installing now...")

                do {
                    var json = try JSONDecoder().decode(RepoMetadata.self, from: data)

                    // install the data in the repo folder
                    let fileManager = FileManager.default
                    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

                    let reposUrl = documentsURL.appendingPathComponent("Repos")

                    let newRepoUrl = reposUrl.appendingPathComponent(json.id)

                    var isDirectory: ObjCBool = false
                    if !fileManager.fileExists(atPath: newRepoUrl.path, isDirectory: &isDirectory) {
                        try fileManager.createDirectory(at: newRepoUrl, withIntermediateDirectories: false, attributes: nil)
                        
                        print("Successfully wrote repository directory.")
                    }

                    json.url = url.absoluteString

                    // add metadata.json file
                    let jsonData = try JSONEncoder().encode(json)
                    try jsonData.write(to: newRepoUrl.appendingPathComponent("metadata.json"), options: [.atomic, .completeFileProtection])
                    
                    print("Successfully wrote metadata.json.")

                    // get icon and store it
                    let (data, response) = try await URLSession.shared.data(from: url.appendingPathComponent("icon.png"))
                    
                    print("Fetched icon.png. Writing...")

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        logger.log("Icon could not be found.")
                        return
                    }

                    try data.write(to: newRepoUrl.appendingPathComponent("icon.png"), options: [.atomic, .completeFileProtection])
                    
                    print("Successfully wrote icon.png")
                } catch {
                    logger.log("JSON Error: \(error.localizedDescription)")
                    return
                }
            },
            installRepoMetadata: { metadata in
                print("Installing repository metadata...")
                do {
                    guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

                    let reposUrl = documentsURL.appendingPathComponent("Repos")
                    let newRepoUrl = reposUrl.appendingPathComponent(metadata.id)
                    
                    if !FileManager.default.fileExists(atPath: newRepoUrl.path) {
                        try FileManager.default.createDirectory(at: newRepoUrl, withIntermediateDirectories: true, attributes: nil)
                        logger.log("Repository folder created at path: \(newRepoUrl)")
                   }
                    
                    let metadataJson = newRepoUrl.appendingPathComponent("metadata.json")
                    
                    if !FileManager.default.fileExists(atPath: metadataJson.path) {
                        if FileManager.default.createFile(atPath: metadataJson.path, contents: nil, attributes: nil) {
                            logger.log("Created metadata.json file.")
                        } else {
                            logger.log("Error creating metadata.json file!")
                        }
                    }

                    let jsonData = try JSONEncoder().encode(metadata)
                    try jsonData.write(to: metadataJson, options: [.atomic, .completeFileProtection])
                    
                    logger.log("Successfully wrote repository metadata.")
                } catch {
                    logger.log("Installing repo metadata failed. Reason: \(error.localizedDescription)")
                }
            },
            installModule: { repoMetadata, id in
                guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                do {
                    let moduleFileUrl = documentsURL
                        .appendingPathComponent("Repos")
                        .appendingPathComponent(repoMetadata.id)
                        .appendingPathComponent("Modules")

                    var isDirectory: ObjCBool = false
                    if !FileManager.default.fileExists(atPath: moduleFileUrl.path, isDirectory: &isDirectory) {
                        try FileManager.default.createDirectory(at: moduleFileUrl, withIntermediateDirectories: false, attributes: nil)
                    }

                    guard let repoPath = repoMetadata.url,
                          let repoUrl = URL(string: repoPath) else {
                        logger.log("Repo Url not found.")
                        return
                    }

                    guard let filePath = repoMetadata.modules?.first { $0.id == id }?.filePath else {
                        logger.log("Filepath of module not found.")
                        return
                    }

                    var fullModuleUrl: URL

                    if let fullURL = URL(string: filePath), fullURL.scheme != nil {
                        fullModuleUrl = fullURL
                    } else {
                        // swiftlint:disable force_unwrapping
                        let resolvedURL = URL(string: filePath, relativeTo: repoUrl)!.absoluteURL
                        // swiftlint:enable force_unwrapping
                        fullModuleUrl = resolvedURL
                    }

                    // download file to modules directory
                    let (data, response) = try await URLSession.shared.data(from: fullModuleUrl)

                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        logger.log("Module could not be found.")
                        return
                    }

                    try data.write(to: moduleFileUrl.appendingPathComponent("Temporary.module"), options: [.atomic, .completeFileProtection])

                    // extract file
                    try FileManager.default.createDirectory(
                        at: moduleFileUrl.appendingPathComponent(id),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    try FileManager.default.unzipItem(
                        at: moduleFileUrl.appendingPathComponent("Temporary.module"),
                        to: moduleFileUrl.appendingPathComponent(id)
                    )

                    // remove temporary file
                    try FileManager.default.removeItem(at: moduleFileUrl.appendingPathComponent("Temporary.module"))
                } catch {
                    logger.log("Installing module failed. Reason: \(error.localizedDescription)")
                }
            },
            deleteRepo: { _ in },
            deleteModule: { _ in },
            getRepo: { id in
                RepoMetadata(id: id, title: "", author: "", description: "", modules: [])
            },
            getRepos: {
                try _getRepos()
            },
            getModulesForRepo: { id in
                let fileManager = FileManager.default

                // Get the path to the user's Documents directory
                guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("Could not locate the Documents directory.")
                    return []
                }

                let repoUrl = documentsDirectory
                    .appendingPathComponent("Repos")
                    .appendingPathComponent(id)
                    .appendingPathComponent("Modules")

                var isDirectory: ObjCBool = false
                if !fileManager.fileExists(atPath: repoUrl.path, isDirectory: &isDirectory) {
                    return []
                }

                let subdirectories = try fileManager.contentsOfDirectory(
                    at: repoUrl,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: .skipsHiddenFiles
                )

                var modules: [Module] = []

                for subdirectory in subdirectories {
                    var isDirectory: ObjCBool = false
                    if fileManager.fileExists(atPath: subdirectory.path, isDirectory: &isDirectory), isDirectory.boolValue {
                        let metadataUrl = subdirectory.appendingPathComponent("metadata.json")
                        if fileManager.fileExists(atPath: metadataUrl.path) {
                            let data = try Data(contentsOf: metadataUrl)

                            let metadata = try JSONDecoder().decode(Module.self, from: data)

                            modules.append(metadata)
                        } else {
                            print("No metadata.json found in \(subdirectory.lastPathComponent)")
                        }
                    }
                }

                return modules
            },
            getModuleData: { id in
                Module(id: id, name: "", author: "", description: "", type: 0, subtypes: [], version: "")
            },
            getModulePathForId: { id in
                guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
                let repos = try _getRepos()

                for repo in repos {
                    logger.log("Checking \(repo.title)\nID: \(repo.id)")
                    let exists = repo.modules?.first(where: { $0.id == id})

                    if let exists {
                        logger.log("Found module in repo \(repo.title)")
                        return documentsURL
                            .appendingPathComponent("Repos")
                            .appendingPathComponent(repo.id)
                            .appendingPathComponent("Modules").appendingPathComponent(id)
                    }
                }
                logger.warning("No module with the id \(id) found.")

                return URL(string: "")
            }
        )
    }()
}
