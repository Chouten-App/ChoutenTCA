//
//  Relay.swift
//  ChoutenRedesign
//
//  Created by Inumaki on 25.01.24.
//

import SwiftUI
import JavaScriptCore
import SharedModels

class Relay: ObservableObject {
    static let shared = Relay()

    let context: JSContext = JSContext()

    @Published var infoData: InfoData? = nil
    @Published var searchResult: SearchResult? = nil

    private init() {
        // Testing.js is temporary, for testing
        // will use actual module in the future

        print("Creating Relay instance")

        context.exceptionHandler = { context, exception in
            // show Error Display
            print(exception?.toString() ?? "Unknown error.")
        }

        testingJS()
        createModuleInstance()

        let checkInstance = context.evaluateScript("instance != undefined")

        if let checkInstance, checkInstance.toBool() {
            DispatchQueue.global(qos: .background).async {
                Task {
                    await self.testDiscover()
                    await self.testInfo()
                    await self.testEpisodes()
                }
            }
        }
    }

    func testException() async {
        let response = context.evaluateScript("instance.servers('hm')")
        if let response {
            do {
                _ = try await response.value()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func testDiscover() async {
        do {
            let response = context.evaluateScript("instance.discover()")
            let value = try await response?.value()

            if let value = value {
                if let dataArray = value.toArray() {
                    var discoverSections = [DiscoverSection]()
                    for dataItem in dataArray {
                        if let dataJSValue = dataItem as? JSValue, let discoverSection = DiscoverSection(jsValue: dataJSValue) {
                            discoverSections.append(discoverSection)
                        }
                    }
                    // Now you have an array of DiscoverSection objects
                    // You can use this array as needed
                    print(discoverSections)
                } else {
                    print("Failed to convert JSValue to array.")
                }
            } else {
                print("Failed to get value from JavaScript response.")
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func testSearch() async {
        do {
            let response = context.evaluateScript("instance.search('query')")
            let value = try await response?.value()

            if let value {
                if let searchData = SearchResult(jsValue: value) {
                    searchResult = searchData
                } else {
                    print("Failed to create Info instance from JSValue.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func testInfo() async {
        do {
            let response = context.evaluateScript("instance.info('hm')")
            let value = try await response?.value()

            if let value {
                if let info = InfoData(jsValue: value) {
                    infoData = info
                } else {
                    print("Failed to create Info instance from JSValue.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func testEpisodes() async {
        do {
            let response = context.evaluateScript("instance.episodes('hm')")
            let value = try await response?.value()

            if let value {
                if let jsArray = value.toArray() as? [[String: Any]] {
                    var mediaLists = [MediaList]()

                    for dict in jsArray {
                        guard let title = dict["title"] as? String,
                              let listDictArray = dict["list"] as? [[String: Any]] else {
                            continue
                        }

                        var mediaItems = [MediaItem]()
                        for itemDict in listDictArray {
                            guard let number = itemDict["number"] as? Double,
                                  let url = itemDict["url"] as? String else {
                                continue
                            }
                            let title = itemDict["title"] as? String
                            let description = itemDict["description"] as? String
                            let image = itemDict["image"] as? String

                            // Here, you can create a MediaItem instance
                            let mediaItem = MediaItem(url: url, number: number, title: title, description: description, image: image)
                            mediaItems.append(mediaItem)
                        }

                        // Here, you can create a MediaList instance
                        let mediaList = MediaList(title: title, list: mediaItems)
                        mediaLists.append(mediaList)
                    }

                    // Now mediaLists contains an array of MediaList objects
                    if var infoData {
                        infoData.mediaList = mediaLists
                    }
                } else {
                    print("Failed to create Info instance from JSValue.")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func testingJS() {
        guard let commonCodePath = Bundle.main.path(forResource: "testing", ofType: "js") else {
            print("Couldnt find testing.js")
            return
        }

        let commonCodeURL = URL(fileURLWithPath: commonCodePath)

        do {
            let commonCode = try String(contentsOf: commonCodeURL)
            context.evaluateScript(commonCode)
        } catch {
            print(error.localizedDescription)
        }
    }

    func createModuleInstance() {
        // Access the TestModule class from the context
        context.evaluateScript("const instance = new source.default();")
    }
}
