//
//  Live.swift
//
//
//  Created by Eltik on 30.7.24.
//

import Foundation
import Dependencies
import SharedModels
import GRDB

extension DatabaseClient: DependencyKey {
    public static let liveValue: Self = {
        @Sendable func fetchDatabasePath() throws -> String {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let modulesDirectory = documentsDirectory.appendingPathComponent("Database")
                let dbPath = modulesDirectory.appendingPathComponent("Collections.sqlite").path
                
                if !FileManager.default.fileExists(atPath: dbPath) {
                    createDatabase()
                }
                
                return dbPath
            } else {
                throw NSError(domain: "Could not fetch database path.", code: 0, userInfo: nil)
            }
        }
        
        @Sendable func createDatabase() {
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileManager = FileManager.default
                
                let cacheDirectory = documentsDirectory.appendingPathComponent("CACHE")
                let databaseDirectory = documentsDirectory.appendingPathComponent("Database")
                
                if !fileManager.fileExists(atPath: databaseDirectory.path) {
                   do {
                       try fileManager.createDirectory(at: databaseDirectory, withIntermediateDirectories: true, attributes: nil)
                       print("Directory created at path: \(databaseDirectory)")
                   } catch {
                       print("Error creating directory: \(error)")
                   }
               } else {
                   print("Directory already exists at path: \(databaseDirectory)")
               }
                
                let databaseFileURL = databaseDirectory.appendingPathComponent("Collections.sqlite")
                if !fileManager.fileExists(atPath: databaseFileURL.path) {
                    if fileManager.createFile(atPath: databaseFileURL.path, contents: nil, attributes: nil) {
                        print("Database file created at path: \(databaseFileURL)")
                    } else {
                        print("Error creating database file.")
                    }
                } else {
                    print("Database file already exists at path: \(databaseFileURL)")
                }
            }
        }
        
        return Self(
            initDB: {
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    try dbQueue.write { db in
                        // This is useless as downloads aren't used yet
                        try db.create(table: "downloads") { t in
                            t.primaryKey("id", .text)
                            t.column("item", .jsonText).notNull()
                        }
                    }
                } catch {
                    print("Error initializing database file!")
                    print("\(error)")
                }
            },
            createCollection: { name in
                let randomId = UUID().uuidString;
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    
                    try dbQueue.write { db in
                        let collectionTableName = "collection-\(randomId)"
                        let itemsTableName = "items-\(randomId)"
                        
                        try db.create(table: collectionTableName) { t in
                            t.column("uuid", .text).primaryKey()
                            t.column("name", .text).notNull()
                        }
                        
                        try db.create(table: itemsTableName) { t in
                            t.column("id", .integer).primaryKey()
                            t.column("collection_uuid", .text).notNull().references(collectionTableName, onDelete: .cascade)
                            t.column("moduleId", .text).notNull()
                            t.column("infoData", .jsonText).notNull()
                        }
                    }
                } catch {
                    print("Error creating collection tables for \(name)!")
                    print("\(error)")
                }
                
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    try dbQueue.write { db in
                        let collectionTableName = "collection-\(randomId)"
                        try db.execute(sql: "INSERT INTO '\(collectionTableName)' (uuid, name) VALUES (?, ?)", arguments: [randomId, name])
                        print("Successfully created collection for \(name). ID: \(randomId)")
                    }
                } catch {
                    print("Error creating base collections for \(name)!")
                    print("\(error)")
                }
                
                return randomId;
            },
            fetchCollection: { id in
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    
                    return try dbQueue.read { db in
                        let items = try Row.fetchAll(db, sql: "SELECT * FROM 'collection-\(id)'")
                        
                        return CollectionData(uuid: "", name: "")
                    }
                } catch {
                    print("Error fetching collection data for \(id)!")
                    print("\(error)")
                }
                return nil;
            },
            fetchCollections: {
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    return try dbQueue.read { db in
                        // Fetch collection table name matching collection_uuid
                        let tables = try String.fetchAll(db, sql: """
                            SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'collection-%'
                        """)
                        
                        var collections: [HomeSection] = []
                        
                        for collectionTable in tables {
                            // Fetch collection data
                            let collectionItems = try Row.fetchAll(db, sql: "SELECT * FROM '\(collectionTable)'")
                            for row in collectionItems {
                                var section = HomeSection(id: row["uuid"], title: row["name"], type: 1, list: [])

                                // Fetch items associated with the collection
                                let itemsTable = "items-\(row["uuid"]!)" // Assuming items table follows this pattern
                                let items = try Row.fetchAll(db, sql: "SELECT * FROM '\(itemsTable)'")

                                var data: [HomeData] = []
                                for itemRow in items {
                                    let stringItem: String = itemRow["infoData"]
                                    do {
                                        let item = try JSONDecoder().decode(CollectionItem.self, from: stringItem.data(using: .utf8)!)
                                        let homeData = HomeData(
                                            url: item.url,
                                            titles: Titles(primary: item.infoData.titles.primary, secondary: item.infoData.titles.secondary ?? ""),
                                            description: item.infoData.description,
                                            poster: item.infoData.poster,
                                            label: Label(text: "Test", color: ""),
                                            indicator: "\(item.infoData.yearReleased)",
                                            current: nil,
                                            total: nil
                                        )
                                        data.append(homeData)
                                    } catch {
                                        continue
                                    }
                                }

                                section.list = data
                                collections.append(section)
                            }
                        }

                        return collections
                    }
                } catch {
                    print("Error fetching collections!")
                    print("\(error)")

                    return []
                }
            },
            isInCollection: { collectionId, moduleId, infoData in
                return true
            },
            addToCollection: { collectionId, moduleId, infoData in
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    try dbQueue.write { db in
                        try db.execute(sql: """
                            INSERT INTO 'items-\(collectionId)' (collection_uuid, moduleId, infoData) VALUES (?, ?, ?);
                        """, arguments: [collectionId, moduleId, try? JSONEncoder().encode(infoData)])
                        print("Successfully added item to the collection for \(infoData.infoData.titles.primary). ID: \(collectionId)")
                    }
                } catch {
                    print("Error adding to collection!")
                    print("\(error)")
                }
            }
        )
    }()
}
