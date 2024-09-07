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
        
        // Centralized function to fetch the database path
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
        
        // Function to create the database and directories
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
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    try dbQueue.write { db in
                        try db.create(table: "continuewatching", options: .ifNotExists) { t in
                            t.column("id", .integer).primaryKey()
                            t.column("moduleId", .text).notNull()
                            t.column("infoData", .jsonText).notNull()
                            t.column("episodeData", .jsonText).notNull()
                        }
                    }

                    try dbQueue.close()
                } catch {
                    print("Error initializing database file!")
                    print("\(error)")
                }
            },
            
            fetchCollection: { id in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    let collection = try dbQueue.read { db in
                        let items = try Row.fetchAll(db, sql: "SELECT * FROM 'collection-\(id)'")
                        
                        return CollectionData(uuid: "", name: "")
                    }
                    
                    try dbQueue.close()
                    
                    return collection
                } catch {
                    print("Error fetching collection data for \(id)!")
                    print("\(error)")
                }
                return nil;
            },
            fetchCollections: {
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    let collections = try dbQueue.read { db in
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
                                            indicator: "\(item.flag.rawValue)",
                                            status: item.flag,
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
                    
                    try dbQueue.close()
                    
                    return collections
                } catch {
                    print("Error fetching collections!")
                    print("\(error)")

                    return []
                }
            },
            isInCollection: { collectionId, moduleId, infoData in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    let exists = try dbQueue.read { db in
                        // Query to check if the item is in the collection
                        let itemExists = try Bool.fetchOne(db, sql: """
                            SELECT EXISTS (
                                SELECT 1
                                FROM 'items-\(collectionId)'
                                WHERE moduleId = ? AND infoData->>'url' = ?
                            )
                        """, arguments: [moduleId, infoData.url])
                        
                        return itemExists ?? false
                    }
                    
                    try dbQueue.close()
                    
                    return exists
                } catch {
                    print("Error checking if item is in collection!")
                    print("\(error)")
                    return false
                }
            },
            
            createCollection: { name in
                let randomId = UUID().uuidString;
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
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
                            t.column("flag", .text).notNull()
                        }
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error creating collection tables for \(name)!")
                    print("\(error)")
                }
                
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    try dbQueue.write { db in
                        let collectionTableName = "collection-\(randomId)"
                        try db.execute(sql: "INSERT INTO '\(collectionTableName)' (uuid, name) VALUES (?, ?)", arguments: [randomId, name])
                        print("Successfully created collection for \(name). ID: \(randomId)")
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error creating base collections for \(name)!")
                    print("\(error)")
                }
                
                return randomId;
            },
            
            addToCollection: { collectionId, moduleId, infoData in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    try dbQueue.write { db in
                        try db.execute(sql: """
                            INSERT INTO 'items-\(collectionId)' (collection_uuid, moduleId, infoData, flag) VALUES (?, ?, ?, ?);
                        """, arguments: [collectionId, moduleId, try? JSONEncoder().encode(infoData), infoData.flag.rawValue])
                        print("Successfully added item to the collection for \(infoData.infoData.titles.primary). ID: \(collectionId)")
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error adding to collection!")
                    print("\(error)")
                }
            },
            updateItemInCollection: { collectionId, moduleId, infoData in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    // For some reason, if I include the moduleId and the moduleId string length is 0, it won't work lol
                    try dbQueue.write { db in
                        try db.execute(sql: """
                            UPDATE 'items-\(collectionId)' SET infoData = ?, flag = ? WHERE infoData->>'url' = ?
                        """, arguments: [try? JSONEncoder().encode(infoData), infoData.flag.rawValue, infoData.url])
                        print("Successfully updated item in the collection for \(infoData.infoData.titles.primary). ID: \(collectionId) Flag: \(infoData.flag.rawValue)")
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error updating item in collection!")
                    print("\(error)")
                }
            },
            removeFromCollection: { collectionId, moduleId, infoData in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    // Same thing as above. For some reason, if I include the moduleId and the moduleId string length is 0, it won't work lol
                    try dbQueue.write { db in
                        try db.execute(sql: """
                            DELETE FROM 'items-\(collectionId)' WHERE infoData->>'url' = ?
                        """, arguments: [infoData.url])
                        print("Successfully deleted item from collection for \(infoData.infoData.titles.primary). ID: \(collectionId)")
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error removing from collection!")
                    print("\(error)")
                }
            },
            removeCollection: { collectionId, moduleId in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    try dbQueue.write { db in
                        let collectionTableName = "collection-\(collectionId)"
                        let itemsTableName = "items-\(collectionId)"
                        
                        // Delete the collection table
                        try db.execute(sql: "DROP TABLE IF EXISTS '\(collectionTableName)'")
                        
                        // Delete the items table
                        try db.execute(sql: "DROP TABLE IF EXISTS '\(itemsTableName)'")
                        
                        print("Successfully deleted collection and items tables for collectionId: \(collectionId)")
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error deleting collection!")
                    print("\(error)")
                }
            },
            
            fetchContinueWatching: {
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    let continueWatchingItems = try dbQueue.read { db in
                        // Fetch all rows from the "continuewatching" table
                        let rows = try Row.fetchAll(db, sql: "SELECT * FROM continuewatching")
                        
                        let randomId = UUID().uuidString;
                        var result = HomeSection(id: randomId, title: "Continue Watching", type: 3, list: [])
                        
                        for row in rows {
                            // Parse each row to create a ContinueWatchingItem object
                            let moduleId: String = row["moduleId"]
                            let infoDataString: String = row["infoData"]
                            let episodeDataString: String = row["episodeData"]
                            
                            do {
                                let item = try JSONDecoder().decode(CollectionItem.self, from: infoDataString.data(using: .utf8)!)
                                let homeData = HomeData(
                                    url: item.url,
                                    titles: Titles(primary: item.infoData.titles.primary, secondary: item.infoData.titles.secondary ?? ""),
                                    description: item.infoData.description,
                                    poster: item.infoData.poster,
                                    label: Label(text: "Test", color: ""),
                                    indicator: "\(item.flag.rawValue)",
                                    status: item.flag,
                                    current: nil,
                                    total: nil
                                )
                                result.list.append(homeData)
                            } catch {
                                continue
                            }
                        }
                        
                        return result
                    }
                    
                    
                    try dbQueue.close()
                    
                    return continueWatchingItems
                } catch {
                    print("Error fetching continue watching!")
                    print("\(error)")

                    let randomId = UUID().uuidString;
                    
                    return HomeSection(id: randomId, title: "Continue Watching", type: 0, list: [])
                }
            },
            
            addToContinueWatching: { moduleId, infoData in
                do {
                    let dbQueue: DatabaseQueue = {
                        let dbPath = try! fetchDatabasePath()
                        return try! DatabaseQueue(path: dbPath)
                    }()
                    
                    // temp need episode data
                    try dbQueue.write { db in
                        try db.execute(sql: """
                            INSERT INTO 'continuewatching' (moduleId, infoData, episodeData) VALUES (?, ?, ?);
                        """, arguments: [moduleId, try? JSONEncoder().encode(infoData), try? JSONEncoder().encode(HomeSection(id: "", title: "", type: 0, list: []))])
                        print("Successfully added item to continue watching for \(infoData.infoData.titles.primary).")
                    }
                    
                    try dbQueue.close()
                } catch {
                    print("Error adding to continue watching!")
                    print("\(error)")
                }
            }
        )
    }()
}
