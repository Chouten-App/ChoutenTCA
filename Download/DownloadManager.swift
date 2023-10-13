//
//  DownloadManager.swift
//  ChoutenTCA
//
//  Created by Inumaki on 06.10.23.
//

import Foundation
import ComposableArchitecture
import UIKit
import OSLog

private enum DownloadManagerKey: DependencyKey {
    static let liveValue = DownloadManager.live
}

extension DependencyValues {
    var DownloadManager: DownloadManager {
        get { self[DownloadManagerKey.self] }
        set { self[DownloadManagerKey.self] = newValue }
    }
}

struct DownloadManager {
    var downloadFile: (_ url: String) throws -> Void
    var storeInfo: (_ infoData: InfoData, _ url: String) -> Void
    var getInfo: (_ filename: String) -> InfoData?
    var searchLocally: (_ query: String) -> [SearchData]
}

extension DownloadManager {
    @Dependency(\.globalData)
    static var globalData
    
    static private var internalClass = DownloadManagerInternal()
    
    static let live = DownloadManager(
        downloadFile: { url in
            print(url)
        },
        storeInfo: { infoData, url in
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let downloadsDirectory = documentsDirectory.appendingPathComponent("Downloads")
            let currentModule = globalData.getModule()
            
            if currentModule == nil { return }
            
            let module = currentModule!
            
            let moduleDirectory = downloadsDirectory.appendingPathComponent(module.id)
            
            let infoDirectory = moduleDirectory.appendingPathComponent(url.safeFileName() ?? infoData.id)
            
            // Check if the Downloads folder exists
            internalClass.createDirIfNotExist(downloadsDirectory)
            
            // Check if the Module folder exists
            internalClass.createDirIfNotExist(moduleDirectory)
            
            // create info folder
            internalClass.createDirIfNotExist(infoDirectory)
            
            // check if a json file exists
            if fileManager.fileExists(atPath: infoDirectory.appendingPathComponent("metadata.json").path) {
                print("metadata.json exists")
            } else {
                print("metadata.json does not exist")
                // store infodata as json
                do {
                    let encoder = JSONEncoder()

                    // Set the output formatting to pretty-printed
                    encoder.outputFormatting = .prettyPrinted
                    let jsonData = try encoder.encode(infoData)

                    // If you want to print the JSON data as a string (for debugging):
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        //print(jsonString)
                    }
                    
                    // Write the JSON data to a file
                    try jsonData.write(to: infoDirectory.appendingPathComponent("metadata.json"))
                } catch {
                    print("Error encoding struct to JSON: \(error)")
                }
            }
            
            // store poster
            internalClass.saveImageFromURL(urlString: infoData.poster, toPath: infoDirectory.appendingPathComponent("poster.jpg").path)
            
            if let banner = infoData.banner {
                internalClass.saveImageFromURL(urlString: banner, toPath: infoDirectory.appendingPathComponent("banner.jpg").path)
            }
        },
        getInfo: { filename in
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let downloadsDirectory = documentsDirectory.appendingPathComponent("Downloads")
            let currentModule = globalData.getModule()
            
            if currentModule == nil { return nil }
            
            let module = currentModule!
            
            let moduleDirectory = downloadsDirectory.appendingPathComponent(module.id)
            
            let infoDirectory = moduleDirectory.appendingPathComponent(filename)
            
            if fileManager.fileExists(atPath: infoDirectory.appendingPathComponent("metadata.json").path) {
                print("metadata.json exists")
                let decoder = JSONDecoder()
                
                do {
                    let data = try Data(contentsOf: infoDirectory.appendingPathComponent("metadata.json"))
                    
                    let infoData = try decoder.decode(InfoData.self, from: data)
                    
                    return infoData
                } catch {
                    error.log(logger: OSLog.downloadManager)
                }
            }
            
            return nil
        },
        searchLocally: { query in
            return internalClass.searchDownloadsFolder(forQuery: query)
        }
    )
}

class DownloadManagerInternal {
    @Dependency(\.globalData)
    static var globalData
    
    func createDirIfNotExist(_ path: URL) {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path.path) {
            do {
                // Create the Downloads folder if it doesn't exist
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                print("\(path.path) created successfully")
            } catch {
                print("Error creating \(path.path): \(error.localizedDescription)")
            }
        } else {
            print("\(path.path) already exists")
        }
    }
    
    func saveImageFromURL(urlString: String, toPath path: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }

            if let data = data, let image = UIImage(data: data) {
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    do {
                        try imageData.write(to: URL(fileURLWithPath: path))
                        print("Image saved to: \(path)")
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
            }
        }.resume()
    }
    
    func searchDownloadsFolder(forQuery query: String) -> [SearchData] {
        let fileManager = FileManager.default
        let documentsFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let downloadsDirectory = documentsFolderURL.appendingPathComponent("Downloads")
        
        let currentModule = DownloadManagerInternal.globalData.getModule()
        if currentModule == nil { return [] }
        
        let module = currentModule!
        
        let moduleDirectory = downloadsDirectory.appendingPathComponent(module.id)
        
        var searchResults: [SearchData] = []
        do {
            let folderContents = try fileManager.contentsOfDirectory(at: moduleDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for folderURL in folderContents {
                // Check if the item is a directory
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    // Read metadata.json file inside the folder
                    let metadataURL = folderURL.appendingPathComponent("metadata.json")
                    if fileManager.fileExists(atPath: metadataURL.path) {
                        do {
                            let metadataData = try Data(contentsOf: metadataURL)
                            let decoder = JSONDecoder()
                            let metadata = try decoder.decode(InfoData.self, from: metadataData)
                            
                            // Perform fuzzy search on metadata titles
                            let primaryTitleMatch = metadata.titles.primary.fuzzyMatch(query: query)
                            let secondaryTitleMatch = metadata.titles.secondary?.fuzzyMatch(query: query)
                            
                            if primaryTitleMatch || (secondaryTitleMatch != nil && secondaryTitleMatch!) {
                                print("Match found in folder: \(folderURL.lastPathComponent)")
                                print("Primary Title: \(metadata.titles.primary)")
                                print("Secondary Title: \(String(describing: metadata.titles.secondary))")
                                print("---")
                                
                                let searchData = SearchData(
                                    url: folderURL.lastPathComponent,
                                    img: folderURL.appendingPathComponent("poster.jpg").path,
                                    title: metadata.titles.primary,
                                    indicatorText: nil,
                                    currentCount: nil,
                                    totalCount: nil
                                )
                                searchResults.append(searchData)
                            }
                            
                            
                        } catch {
                            print("Error decoding metadata: \(error)")
                        }
                    }
                }
            }
        } catch {
            print("Error reading contents of Downloads folder: \(error)")
        }
        
        return searchResults
    }
}
