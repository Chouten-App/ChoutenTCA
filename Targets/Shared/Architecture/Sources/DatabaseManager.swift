//
//  DatabaseManager.swift
//  Architecture
//
//  Created by Inumaki on 16.07.24.
//

import Foundation
import GRDB
import SharedModels

// swiftlint:disable force_unwrapping
public class DatabaseManager {
    public static let shared = DatabaseManager()
    private var dbQueue: DatabaseQueue?

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let databaseURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("db.sqlite")

            dbQueue = try DatabaseQueue(path: databaseURL.path)

            try dbQueue?.write { db in
                try db.create(table: "MediaItem", ifNotExists: true) { t in
                    t.autoIncrementedPrimaryKey("id")
                    t.column("url", .text).notNull()
                    t.column("number", .double).notNull()
                    t.column("title", .text)
                    t.column("language", .text)
                    t.column("description", .text)
                    t.column("thumbnail", .text)
                    t.column("isWatched", .boolean).notNull().defaults(to: false)
                }
            }
        } catch {
            print("Failed to set up database: \(error.localizedDescription)")
        }
    }

    public func saveMediaItem(_ item: MediaItem) {
        do {
            try dbQueue?.write { db in
                try item.insert(db)
            }
        } catch {
            print("Failed to save media item: \(error.localizedDescription)")
        }
    }

    public func updateMediaItem(_ item: MediaItem) {
        do {
            try dbQueue?.write { db in
                try item.upsert(db)
            }
        } catch {
            print("Failed to update media item: \(error.localizedDescription)")
        }
    }

    public func fetchMediaItems() -> [MediaItem] {
        do {
            return try dbQueue!.read { db in
                try MediaItem.fetchAll(db)
            }
        } catch {
            print("Failed to fetch media items: \(error.localizedDescription)")
        }
        return []
    }

    public func markAsWatched(url: String) {
        do {
            try dbQueue?.write { db in
                guard var item = try MediaItem.fetchOne(db, key: url) else {
                    return
                }
                item.isWatched = true
                try item.update(db)
            }
        } catch {
            print("Failed to mark as watched: \(error.localizedDescription)")
        }
    }

    public func isWatched(url: String) -> Bool {
        do {
            return try dbQueue!.read { db in
                let item = try MediaItem.fetchOne(db, key: url)
                return item?.isWatched ?? false
            }
        } catch {
            print("Failed to check if watched: \(error.localizedDescription)")
        }
        return false
    }

    public func fetchWatchedURLs() -> [String] {
        do {
            return try dbQueue!.read { db in
                let rows = try Row.fetchAll(db, sql: "SELECT url FROM MediaItem WHERE isWatched = ?", arguments: [true])
                return rows.compactMap { $0["url"] as? String }
            }
        } catch {
            print("Failed to fetch watched URLs: \(error.localizedDescription)")
        }
        return []
    }
}
// swiftlint:enable force_unwrapping
