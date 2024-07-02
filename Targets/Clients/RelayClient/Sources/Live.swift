//
//  File.swift
//
//
//  Created by Inumaki on 19.04.24.
//

import Architecture
import Combine
import Dependencies
import Foundation
import OSLog
import SharedModels
import ZIPFoundation

public enum RelayError: Error {
    case jsNotFound
    case malformedModule
    case malformedData
    case malformedJS
    case infoConversionFailed
    case infoFunctionFailed
    case searchConversionFailed
    case searchFunctionFailed
    case mediaConversionFailed
    case mediaFunctionFailed
    // SendRequest Errors
    case invalidURL
    case httpRequestFailed
    case invalidResponseData
    case sessionError(error: Error)
}

extension RelayClient: DependencyKey {
    public static let liveValue: Self = {
        let logger = Logger(subsystem: "com.inumaki.Chouten", category: "RelayClient")

        var selectedModule: Module?

        return Self(
            loadModule: { fileURL in
                logger.info("Module load triggered.")
                var module: Module?
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileManager = FileManager.default

                    logger.info("Checking if module exists")
                    if !fileManager.fileExists(atPath: fileURL.appendingPathComponent("metadata.json").path) {
                        logger.error("JS does not exist at \(fileURL).")
                        throw RelayError.jsNotFound
                    }

                    logger.info("Fetching js.")
                    let moduleData = try? Data(contentsOf: fileURL.appendingPathComponent("metadata.json"))

                    if let moduleData {
                        module = try JSONDecoder().decode(Module.self, from: moduleData)

                        // client.setSelectedModule(module)
                    } else {
                        logger.error("Data of js is malformed.")
                        throw RelayError.malformedData
                    }

                    logger.info("Checking if js file exists.")
                    if !fileManager.fileExists(atPath: fileURL.appendingPathComponent("code.js").path) {
                        logger.error("JS does not exist at \(fileURL).")
                        throw RelayError.jsNotFound
                    }

                    logger.info("Fetching js.")
                    let jsData = try? Data(contentsOf: fileURL.appendingPathComponent("code.js"))

                    if let jsData {
                        let jsString = String(data: jsData, encoding: .utf8)

                        if let jsString {
                            Relay.shared.resetModule()
                            Relay.shared.evaluateScript(jsString)
                            Relay.shared.createModuleInstance()
                        } else {
                            logger.error("String of js is malformed.")
                            throw RelayError.malformedJS
                        }
                    } else {
                        logger.error("Data of js is malformed.")
                        throw RelayError.malformedData
                    }
                }
                return module
            },
            info: { url in
                logger.log("Fetching Info data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.info('\(url)')")

                if let value {
                    logger.log("Converting jsValue to InfoData.")
                    if let info = InfoData(jsValue: value) {
                        return info
                    }

                    logger.error("Converting the jsValue to InfoData failed.")
                    throw RelayError.infoConversionFailed
                }

                logger.error("Info function failed to return a value.")
                throw RelayError.infoFunctionFailed
            },
            search: { url, page in
                logger.log("Fetching Search data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.search('\(url)', \(page))")

                if let value {
                    logger.log("Converting jsValue to SearchResult.")
                    if let searchResult = SearchResult(jsValue: value) {
                        return searchResult
                    }

                    logger.error("Converting the jsValue to SearchResult failed.")
                    throw RelayError.searchConversionFailed
                }

                logger.error("Search function failed to return a value.")
                throw RelayError.searchFunctionFailed
            },
            discover: {
                logger.log("discover")
                return await getDiscover()
            },
            media: { url in
                logger.log("media")

                let value = try? await Relay.shared.callAsyncFunction("instance.media('\(url)')")

                if let value {
                    logger.log("Converting jsValue to Media List.")
                    if let mediaList = value.toMediaListArray() {
                        return mediaList
                    }

                    logger.error("Converting the jsValue to Media List failed.")
                    throw RelayError.mediaConversionFailed
                }

                logger.error("Media function failed to return a value.")
                throw RelayError.mediaFunctionFailed
            },
            servers: { url in
                logger.log("servers")

                let value = try? await Relay.shared.callAsyncFunction("instance.servers('\(url)')")

                if let value {
                    logger.log("Converting jsValue to Server List.")
                    if let servers = value.toServerDataArray() {
                        return servers
                    }

                    logger.error("Converting the jsValue to Server List failed.")
                    throw RelayError.mediaConversionFailed
                }

                logger.error("Server function failed to return a value.")
                throw "Server error: \(url)"
            },
            sources: { url in
                logger.log("sources")

                let value = try? await Relay.shared.callAsyncFunction("instance.sources('\(url)')")

                if let value {
                    logger.log("Converting jsValue to Source Data.")
                    return VideoData(jsValue: value)
                }

                logger.error("Source function failed to return a value.")

                throw "Source error: \(url)"
            },
            importFromFile: { fileUrl in
                throw "\(fileUrl)"
            }
        )
    }()

    private static func getDiscover() async -> [DiscoverSection] {
        await Relay.shared.getDiscover()
    }
}
