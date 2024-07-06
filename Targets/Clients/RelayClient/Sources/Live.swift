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
import UIKit
import ViewComponents
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

        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first

        var selectedModule: Module?

        @Sendable
        func log(_ title: String, description: String, type: LogType = .info) {
            switch type {
            case .info:
                logger.info("\(description)")
            case .warning:
                logger.warning("\(description)")
            case .error:
                logger.error("\(description)")
            }

            LogManager.shared.log(title, description: description, line: "")

            if type == .error {
                DispatchQueue.main.async {
                    window?.rootViewController?.view.showErrorDisplay(
                        message: title,
                        description: description,
                        indicator: "Relay",
                        type: ErrorType.error
                    )
                }
            }
        }

        return Self(
            loadModule: { fileURL in
                logger.info("Module load triggered.")
                var module: Module?
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileManager = FileManager.default

                    logger.info("Checking if module exists")
                    if !fileManager.fileExists(atPath: fileURL.appendingPathComponent("metadata.json").path) {
                        log("Relay Error", description: "Metadata does not exist at \(fileURL)", type: .error)
                        throw RelayError.jsNotFound
                    }

                    logger.info("Fetching js.")
                    let moduleData = try? Data(contentsOf: fileURL.appendingPathComponent("metadata.json"))

                    if let moduleData {
                        module = try JSONDecoder().decode(Module.self, from: moduleData)
                    } else {
                        log("Relay Error", description: "Data of js is malformed.", type: .error)
                        throw RelayError.malformedData
                    }

                    logger.info("Checking if js file exists.")
                    if !fileManager.fileExists(atPath: fileURL.appendingPathComponent("code.js").path) {
                        log("Relay Error", description: "JS does not exist at \(fileURL).", type: .error)
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
                            log("Relay Error", description: "String of js is malformed.", type: .error)
                            throw RelayError.malformedJS
                        }
                    } else {
                        log("Relay Error", description: "Data of js is malformed.", type: .error)
                        throw RelayError.malformedData
                    }
                }
                return module
            },
            info: { url in
                log("Info", description: "Fetching Info Data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.info('\(url)')")

                if let value {
                    log("Info", description: "Converting jsValue to InfoData.")
                    if let info = InfoData(jsValue: value) {
                        return info
                    }

                    log("Info", description: "Converting the jsValue to InfoData failed.", type: .error)
                    throw RelayError.infoConversionFailed
                }

                log("Info", description: "Info function failed to return a value.", type: .error)
                throw RelayError.infoFunctionFailed
            },
            search: { url, page in
                log("Search", description: "Fetching Search Data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.search('\(url)', \(page))")

                if let value {
                    log("Search", description: "Converting jsValue to SearchResult.")
                    if let searchResult = SearchResult(jsValue: value) {
                        return searchResult
                    }

                    log("Search", description: "Converting the jsValue to SearchResult failed.", type: .error)
                    throw RelayError.searchConversionFailed
                }

                log("Search", description: "Search function failed to return a value.", type: .error)
                throw RelayError.searchFunctionFailed
            },
            discover: {
                log("Discover", description: "Fetching Discover Data.")
                return await getDiscover()
            },
            media: { url in
                log("Media", description: "Fetching Media Data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.media('\(url)')")

                if let value {
                    log("Media", description: "Converting jsValue to Media List.")
                    if let mediaList = value.toMediaListArray() {
                        return mediaList
                    }

                    log("Media", description: "Converting the jsValue to Media List failed.", type: .error)
                    throw RelayError.mediaConversionFailed
                }

                log("Media", description: "Media function failed to return a value.", type: .error)
                throw RelayError.mediaFunctionFailed
            },
            servers: { url in
                log("Servers", description: "Fetching Server Data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.servers('\(url)')")

                if let value {
                    log("Servers", description: "Converting jsValue to Server List.")
                    if let servers = value.toServerDataArray() {
                        return servers
                    }

                    log("Servers", description: "Converting the jsValue to Server List failed.", type: .error)
                    throw RelayError.mediaConversionFailed
                }

                log("Servers", description: "Server function failed to return a value.", type: .error)
                throw "Server error: \(url)"
            },
            sources: { url in
                log("Sources", description: "Fetching Source Data.")

                let value = try? await Relay.shared.callAsyncFunction("instance.sources('\(url)')")

                if let value {
                    log("Sources", description: "Converting jsValue to Source Data.")
                    return VideoData(jsValue: value)
                }

                log("Sources", description: "Source function failed to return a value.", type: .error)

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
