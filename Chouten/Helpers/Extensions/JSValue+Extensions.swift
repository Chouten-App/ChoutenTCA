//
//  JSValue+Extensions.swift
//  Chouten
//
//  Created by Inumaki on 16/10/2024.
//

import Foundation
import JavaScriptCore

extension JSValue {
    subscript(_ key: String) -> JSValue? {
        guard !isOptional else {
            return nil
        }
        guard let value = forProperty(key) else {
            return nil
        }
        return !value.isOptional ? value : nil
    }

    @discardableResult
    func value() async throws -> JSValue {
        try await withCheckedThrowingContinuation { continuation in
            let onFufilled: @convention(block) (JSValue) -> Void = { value in
                continuation.resume(returning: value)
            }

            let onRejected: @convention(block) (JSValue) -> Void = { value in
                continuation.resume(throwing: value.toError())
            }

            self.invokeMethod(
                "then",
                withArguments: [
                    unsafeBitCast(onFufilled, to: JSValue.self),
                    unsafeBitCast(onRejected, to: JSValue.self)
                ]
            )
        }
    }

    func toError(_ functionName: String? = nil, stackTrace _: Bool = true) -> JSValueError { .init(self, functionName) }
}

/*
extension JSValue {
    // swiftlint:disable line_length
     func toMediaListArray() -> [MediaList]? {
        guard isArray else {
            return nil
        }

        if let jsArray = self.toArray() as? [[String: Any]] {
            var mediaLists = [MediaList]()

            for dict in jsArray {
                guard let title = dict["title"] as? String,
                      let listDictArray = dict["pagination"] as? [[String: Any]] else {
                    continue
                }

                var pagination = [Pagination]()
                for itemDict in listDictArray {
                    guard let id = itemDict["id"] as? String,
                          let itemsDict = itemDict["items"] as? [[String: Any]] else {
                        continue
                    }
                    let title = itemDict["title"] as? String
                    var mediaItems = [MediaItem]()
                    for item in itemsDict {
                        guard
                            let url = item["url"] as? String,
                            let number = item["number"] as? Double
                        else {
                            continue
                        }

                        let title = item["title"] as? String
                        let indicator = item["indicator"] as? String
                        let description = item["description"] as? String
                        let image = item["thumbnail"] as? String

                        let mediaItem = MediaItem(url: url, number: number, title: title, thumbnail: image, description: description, indicator: indicator)

                        mediaItems.append(mediaItem)
                    }
                    let mediaList = Pagination(id: id, title: title, items: mediaItems)
                    pagination.append(mediaList)
                }

                let mediaList = MediaList(title: title, pagination: pagination)
                mediaLists.append(mediaList)
            }

            return mediaLists
        } else {
            print("Failed to create Info instance from JSValue.")
            return nil
        }
    }
    // swiftlint:enable line_length

     func toSourceDataArray() -> [SourceList]? {
        guard isArray else {
            return nil
        }

        if let jsArray = self.toArray() as? [[String: Any]] {
            var serverListArray = [SourceList]()

            for dict in jsArray {
                guard let title = dict["title"] as? String,
                      let listDictArray = dict["sources"] as? [[String: Any]] else {
                    continue
                }

                var list: [SourceData] = []
                for itemDict in listDictArray {
                    guard let url = itemDict["url"] as? String,
                          let name = itemDict["name"] as? String else {
                        continue
                    }
                    let serverData = SourceData(name: name, url: url)
                    list.append(serverData)
                }

                // Here, you can create a MediaList instance
                let serverList = SourceList(title: title, list: list)
                serverListArray.append(serverList)
            }

            return serverListArray
        } else {
            print("Failed to create Info instance from JSValue.")
            return nil
        }
    }

     func toSkipTimeArray() -> [SkipTime] {
        guard isArray else {
            return []
        }

        if let jsArray = self.toArray() as? [[String: Any]] {
            var skipTimeArray = [SkipTime]()

            for dict in jsArray {
                guard let start = dict["start"] as? Double,
                      let end = dict["end"] as? Double,
                      let title = dict["title"] as? String else {
                    continue
                }

                // Here, you can create a MediaList instance
                let skipTime = SkipTime(start: start, end: end, type: title)
                skipTimeArray.append(skipTime)
            }

            return skipTimeArray
        } else {
            print("Failed to create skip times.")
            return []
        }
    }

     func toSubtitlesArray() -> [Subtitle] {
        guard isArray else {
            return []
        }

        if let jsArray = self.toArray() as? [[String: Any]] {
            var subtitlesArray = [Subtitle]()

            for dict in jsArray {
                guard let url = dict["url"] as? String,
                      let language = dict["language"] as? String else {
                    continue
                }

                // Here, you can create a MediaList instance
                let subtitle = Subtitle(url: url, language: language)
                subtitlesArray.append(subtitle)
            }

            return subtitlesArray
        } else {
            print("Failed to create skip times.")
            return []
        }
    }

     func toStreamsArray() -> [Stream] {
        guard isArray else {
            return []
        }

        if let jsArray = self.toArray() as? [[String: Any]] {
            var sourcesArray = [Stream]()

            for dict in jsArray {
                guard let quality = dict["quality"] as? String,
                      let file = dict["file"] as? String,
                      let typeInt = dict["type"] as? Int else {
                    continue
                }

                var sourceType: String = ""
                switch typeInt {
                case 0:
                    sourceType = "hls"
                case 1:
                    sourceType = "mp4"
                default:
                    sourceType = "hls"
                }

                // Here, you can create a MediaList instance
                let source = Stream(file: file, type: sourceType, quality: quality)
                sourcesArray.append(source)
            }

            return sourcesArray
        } else {
            print("Failed to create skip times.")
            return []
        }
    }
}
*/
