//
//  CollectionItem.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//

import Foundation
import JavaScriptCore

 struct InfoData: Codable, Equatable, Sendable {
     var url: String = ""
     let titles: Titles
     let tags: [String]
     let description: String
     let poster: String
     let banner: String?
     let status: String?
     let mediaType: String
     let yearReleased: Int
     var seasons: [SeasonData]
     var mediaList: [MediaList]

     var sanitizedDescription: String {
        let regexPattern = "<[^>]+>"

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: description.count)
            let cleanedString = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "")
            return cleanedString
        } catch {
            return description
        }
    }

     init(titles: Titles, tags: [String], description: String, poster: String, banner: String?, status: String?, mediaType: String, yearReleased: Int, seasons: [SeasonData], mediaList: [MediaList]) {
        self.titles = titles
        self.tags = tags
        self.description = description
        self.poster = poster
        self.banner = banner
        self.status = status
        self.mediaType = mediaType
        self.yearReleased = yearReleased
        self.seasons = seasons
        self.mediaList = mediaList
    }
     
     mutating func setUrl(_ newUrl: String) {
         url = newUrl
     }

     static let freeToUseData = Self(
        titles: Titles(primary: "Big Buck Bunny", secondary: "Blender Foundation"),
        tags: [
            "2008",
            "Blender",
            "Open-Source film"
        ],
        description: """
        The plot follows a day in the life of Big Buck Bunny, during which time he meets three
        bullying rodents: the leader, Frank the flying squirrel, and his sidekicks Rinky the
        red squirrel and Gimera the chinchilla. The rodents amuse themselves by harassing
        helpless creatures of the forest by throwing fruits, nuts, and rocks at them.\nAfter
        the rodents kill two butterflies with an apple and a rock, and then attack Bunny, he
        sets aside his gentle nature and orchestrates a complex plan to avenge the two
        butterflies.\nUsing a variety of traps, Bunny first dispatches Rinky and Gimera.
        Frank, unaware of the fate of the other two, is seen taking off from a tree, and
        gliding towards a seemingly unsuspecting Bunny. Once airborne, Frank triggers Bunny's
        final series of traps, causing Frank to crash into a tree branch and plummet into a
        spike trap below. At the last moment, Frank grabs onto what he believes is the branch
        of a small tree, but discovers it is just a twig Bunny is holding over the spikes.
        Bunny snatches up Frank.\n\nThe film concludes with Bunny being pleased with himself
        as a butterfly flies past him holding a string, at the end of which is Frank
        attached as a flying kite.
        """,
        poster: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Big_buck_bunny_poster_big.jpg/440px-Big_buck_bunny_poster_big.jpg",
        banner: "https://hoststreamsell-pics.s3.amazonaws.com/600c26a209974338f4a579055e7ef61f_big.jpg",
        status: "Finished",
        mediaType: "Episodes",
        yearReleased: 2024,
        seasons: [],
        mediaList: [
            MediaList(
                title: "Movie",
                pagination: [
                    Pagination(
                        id: "",
                        title: "",
                        items: [
                            MediaItem(
                                url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
                                number: 1.0,
                                title: "Movie",
                                thumbnail: "https://www.protocol.com/media-library/big-buck-bunny.png?id=28250459&width=1245&height=700&quality=85&coordinates=0%2C0%2C0%2C0", description: nil
                            )
                        ]
                    )
                ]
            )
        ]
    )

     static let sample = Self(
        titles: Titles(primary: "Primary", secondary: "Secondary"),
        tags: ["Tag 1"],
        description: """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
        exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
        irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat
        nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa
        qui officia deserunt mollit anim id est laborum.
        """,
        poster: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg",
        banner: nil,
        status: "Finished",
        mediaType: "Episodes",
        yearReleased: 2024,
        seasons: [],
        mediaList: [
            MediaList(
                title: "Season 1",
                pagination: [
                    Pagination(
                        id: "",
                        title: "",
                        items: [
                            MediaItem(url: "", number: 1.0, title: "Title", thumbnail: "https://cdn.pixabay.com/photo/2019/07/22/20/36/mountains-4356017_1280.jpg", description: "Description")
                        ]
                    )
                ]
            )
        ]
    )
}

extension InfoData {
     init?(jsValue: JSValue) {
        guard let titlesJSValue = jsValue["titles"] else {
            print("Failed to convert 'titles'")
            return nil
        }
        guard let titles = Titles(jsValue: titlesJSValue) else {
            print("Failed to convert 'titles'")
            return nil
        }

        guard let tags = jsValue["altTitles"]?.toArray() as? [String] else {
            print("Failed to convert 'tags'")
            return nil
        }

        guard let description = jsValue["description"]?.toString() else {
            print("Failed to convert 'description'")
            return nil
        }

        guard let poster = jsValue["poster"]?.toString() else {
            print("Failed to convert 'poster'")
            return nil
        }

        guard let mediaType = jsValue["mediaType"]?.toInt32() else {
            print("Failed to convert 'mediaType'")
            return nil
        }

        guard let yearReleased = jsValue["yearReleased"]?.toInt32() else {
            print("Failed to convert 'yearReleased'")
            return nil
        }

        guard let seasonsJSValue = jsValue["seasons"] else {
            print("Failed to convert 'seasons'")
            return nil
        }

        let seasons: [SeasonData] = seasonsJSValue.toArray().compactMap { element in
            if let jsElement = element as? [String: Any] {
                guard let name = jsElement["name"] as? String, let url = jsElement["url"] as? String
                else {
                    return nil
                }

                let selected = jsElement["selected"] as? Bool
                return SeasonData(name: name, url: url, selected: selected) // SeasonData(jsValue: jsElement)
            } else {
                print("Failed to convert 'seasons' element")
                return nil
            }
        }

        let banner = jsValue["banner"]?.toString()
        let status = jsValue["status"]?.toInt32()

        var computedMediaType: String {
            switch mediaType {
            case 0:
                return "Episodes"
            case 1:
                return "Chapters"
            case _:
                return "Unknown"
            }
        }

        var computedStatus: String {
            switch status {
            case 0:
                return "Finished"
            case 1:
                return "Currently Airing"
            case 2:
                return "On Hiatus"
            case 3:
                return "Unreleased"
            case _:
                return "Unknown"
            }
        }

        print("successful conversion")

        self.init(
            titles: titles,
            tags: tags,
            description: description,
            poster: poster,
            banner: banner,
            status: computedStatus,
            mediaType: computedMediaType,
            yearReleased: Int(yearReleased),
            seasons: seasons,
            mediaList: []
        )
    }
}
