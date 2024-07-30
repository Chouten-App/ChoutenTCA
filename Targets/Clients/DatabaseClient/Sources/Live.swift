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
                        try db.create(table: "collection-\(randomId)") { t in
                            t.column("uuid", .text).primaryKey()
                            t.column("name", .text).notNull()
                        }
                        
                        try db.create(table: "items-\(randomId)") { t in
                            t.column("id", .integer).primaryKey()
                            t.column("collection_uuid", .text).notNull().references("collection-\(randomId)", onDelete: .cascade)
                            t.column("moduleId", .text).notNull()
                            t.column("infoData", .jsonText).notNull()
                            t.column("mediaInfo", .jsonText).notNull()
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
                        try db.execute(literal: """
                            INSERT INTO 'collection-\(randomId)' (uuid, name) VALUES (\(randomId), \(name)
                        """)
                        print("Successfully created collection for \(name). ID: \(randomId)")
                    }
                } catch {
                    print("Error creating base collections for \(name)!")
                    print("\(error)")
                }
                
                return randomId;
            },
            fetchCollections: {
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    return try dbQueue.read { db in
                        // Fetch all collection table names
                        let tables = try String.fetchAll(db, sql: """
                            SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'collection-%'
                        """)
                        
                        var collections: [HomeSection] = []
                        
                        for table in tables {
                            let items = try Row.fetchAll(db, sql: "SELECT * FROM '\(table)'")
                            if (items.count < 5) {
                                continue;
                            }
                            
                            var data: [HomeData] = []
                            for row in items {
                                let stringItem: String = row["mediaInfo"]
                                do {
                                    let item = try JSONDecoder().decode(MediaItem.self, from: stringItem.data(using: .utf8)!)
                                    let homeData = HomeData(url: item.url, titles: Titles(primary: item.title ?? "", secondary: nil), description: item.description ?? "", poster: item.thumbnail ?? "", label: Label(text: "Test", color: ""), indicator: "Thing", current: nil, total: nil)
                                    data.append(homeData)
                                } catch {
                                    continue
                                }
                            }
                            var section: HomeSection = HomeSection(title: "Test", type: 0, list: data)
                            collections.append(section)
                        }
                        
                        return collections;
                    }
                } catch {
                    print("Error fetching collections!")
                    print("\(error)")
                    
                    return []
                }
            },
            fetchCollection: { id in
                do {
                    let dbPath = try fetchDatabasePath()
                    let dbQueue = try DatabaseQueue(path: dbPath)
                    return try dbQueue.read { db in
                        let items = try Row.fetchAll(db, sql: "SELECT * FROM 'collection-\(id)'")
                        
                        var data: [MediaItem] = []
                        for row in items {
                            let item: String = row["mediaInfo"]
                            do {
                                data.append(try JSONDecoder().decode(MediaItem.self, from: item.data(using: .utf8)!))
                            } catch {
                                continue
                            }
                        }
                        return data
                    }
                } catch {
                    print("Error fetching collection for \(id)!")
                    print("\(error)")
                    
                    return []
                }
            }
        )
    }()
}
