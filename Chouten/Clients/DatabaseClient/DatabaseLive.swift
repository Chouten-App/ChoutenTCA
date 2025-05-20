//
//  Live.swift
//
//
//  Created by Eltik on 30.7.24.
//

import Core
import Foundation
import Dependencies
import CoreData

// Helper function to format seconds into a time string
fileprivate func formatTimeSeconds(_ seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    
    if hours > 0 {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    } else {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension DatabaseClient: DependencyKey {
     static let liveValue: Self = {
        let persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "UserCollections")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()

        let context = persistentContainer.viewContext
        
        return Self(
            initDB: {
            },
            fetchCollection: { id in
                let fetchRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", id) // Assuming 'uuid' is the identifier

                do {
                    // Execute the fetch request
                    let collections = try context.fetch(fetchRequest)
                    
                    // Check if any collection was found
                    if let collection = collections.first {
                        // Create and return CollectionData from the found collection
                        return CollectionData(uuid: collection.uuid ?? "", name: collection.name ?? "")
                    }
                } catch {
                    print("Error fetching collection data for \(id)! \(error)")
                }
                
                return nil
            },
            fetchCollections: {
                var homeSections: [HomeSection] = []
                // Create a fetch request for the Collection entity
                let fetchRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                
                do {
                    // Perform the fetch
                    let collections = try context.fetch(fetchRequest)

                    for collection in collections {
                        // Create HomeSection for each collection
                        var section = HomeSection(id: collection.uuid ?? "", title: collection.name ?? "", type: 1, list: [])
                        
                        // Fetch associated items
                        if let items = collection.items as? Set<UserItem> {
                            var data: [HomeData] = []
                            
                            for item in items {
                                print(item)
                                // Assume `infoData` is stored as Data or JSON
                                do {
                                    let itemData = item.infoData // Assuming this is of type Data
                                    if let itemData {
                                        let collectionItem = try JSONDecoder().decode(CollectionItem.self, from: itemData)
                                        
                                        let homeData = HomeData(
                                            url: collectionItem.url,
                                            titles: Titles(primary: collectionItem.infoData.titles.primary, secondary: collectionItem.infoData.titles.secondary ?? ""),
                                            description: collectionItem.infoData.description,
                                            poster: collectionItem.infoData.poster,
                                            label: Label(text: "Test", color: ""),
                                            indicator: "\(collectionItem.flag.rawValue)",
                                            status: collectionItem.flag,
                                            current: nil,
                                            total: nil
                                        )
                                        data.append(homeData)
                                    }
                                } catch {
                                    continue
                                }
                            }

                            section.list = data
                        }

                        homeSections.append(section)
                    }

                } catch {
                    print("Error fetching collections!")
                    print("\(error)")
                }

                return homeSections
            },
            isInCollection: { collectionId, moduleId, infoData in
                let fetchRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", collectionId)

                do {
                    // Fetch the collection
                    let collections = try context.fetch(fetchRequest)
                    
                    // Check if the collection exists
                    if let collection = collections.first {
                        // Check for the existence of the item in the collection
                        if let items = collection.items as? Set<UserItem> {
                            for item in items {
                                // Compare the moduleId and infoData.url
                                if item.moduleId == moduleId,
                                   let itemInfoDataBinary = item.infoData,
                                    let itemInfoData = try? JSONDecoder().decode(InfoData.self, from: itemInfoDataBinary),
                                   itemInfoData.url == infoData.url {
                                    return true // Item exists
                                }
                            }
                        }
                    }
                } catch {
                    print("Error checking if item is in collection!")
                    print("\(error)")
                }
                
                return false // Item does not exist
            },
            createCollection: { name in
                let randomId = UUID().uuidString

                // Create a new Collection instance
                let collection = UserCollection(context: context)
                collection.uuid = randomId
                collection.name = name

                do {
                    // Save the context to persist the new collection
                    try context.save()
                    print("Successfully created collection for \(name). ID: \(randomId)")
                } catch {
                    print("Error creating base collection for \(name)!")
                    print("\(error)")
                }
                
                return randomId
            },
            addToCollection: { collectionId, moduleId, infoData in
                let fetchRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", collectionId)

                do {
                    // Fetch the collection
                    let collections = try context.fetch(fetchRequest)
                    
                    // Check if the collection exists
                    if let collection = collections.first {
                        // Create a new Item instance
                        let item = UserItem(context: context)
                        item.collection = collection
                        item.moduleId = moduleId
                        item.infoData = try? JSONEncoder().encode(infoData)
                        item.flag = infoData.flag.rawValue // Assuming flag is a string
                        
                        // Add the item to the collection's items set
                        if let mutableItems = collection.items as? NSMutableSet {
                            mutableItems.add(item)
                        } else {
                            print("Could not cast items to NSMutableSet.")
                        }

                        // Save the context to persist the new item
                        try context.save()
                        print("Successfully added item to the collection for \(infoData.infoData.titles.primary). ID: \(collectionId)")
                    } else {
                        print("Collection with ID \(collectionId) not found.")
                    }
                } catch {
                    print("Error adding to collection!")
                    print("\(error)")
                }
            },
            updateCollectionName: { collectionId, name in
                let fetchRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", collectionId)

                do {
                    // Fetch the collection
                    let collections = try context.fetch(fetchRequest)
                    
                    // Check if the collection exists
                    if let collection = collections.first {
                        collection.name = name

                        // Save the context to persist the new item
                        try context.save()
                        print("Successfully update collection \(collectionId)")
                    } else {
                        print("Collection with ID \(collectionId) not found.")
                    }
                } catch {
                    print("Error updating name of collection!")
                    print("\(error)")
                }
            },
            updateItemInCollection: { collectionId, moduleId, infoData in
                let fetchRequest: NSFetchRequest<UserItem> = UserItem.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "collection.uuid == %@", collectionId)

                do {
                    // Fetch the items
                    let items = try context.fetch(fetchRequest)
                    
                    let filteredItems = items.filter { userItem in
                        if let itemInfoData = userItem.infoData {
                            // Attempt to decode the infoData to the expected type
                            if let json = try? JSONSerialization.jsonObject(with: itemInfoData, options: []) as? [String: Any],
                               let urlString = json["url"] as? String {
                                return urlString == infoData.url
                            }
                        }
                        return false
                    }
                    
                    // Check if the item exists
                    if let item = filteredItems.first {
                        // Update the properties
                        item.infoData = try? JSONEncoder().encode(infoData)
                        item.flag = infoData.flag.rawValue
                        
                        // Save the context to persist the changes
                        try context.save()
                        print("Successfully updated item in the collection for \(infoData.infoData.titles.primary). ID: \(collectionId) Flag: \(infoData.flag.rawValue)")
                    } else {
                        print("Item not found in collection with ID \(collectionId) and URL \(infoData.url).")
                    }
                } catch {
                    print("Error updating item in collection!")
                    print("\(error)")
                }
            },
            removeFromCollection: { collectionId, moduleId, infoData in
                let fetchRequest: NSFetchRequest<UserItem> = UserItem.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "collection.uuid == %@", collectionId)
                if var predicate = fetchRequest.predicate {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                        predicate,
                        NSPredicate(format: "infoData.url == %@", infoData.url) // Assuming infoData has a `url` property
                    ])
                }

                do {
                    // Fetch the items
                    let items = try context.fetch(fetchRequest)
                    
                    // Check if the item exists
                    if let item = items.first {
                        // Delete the item from the context
                        context.delete(item)
                        
                        // Save the context to persist the changes
                        try context.save()
                        print("Successfully deleted item from collection for \(infoData.infoData.titles.primary). ID: \(collectionId)")
                    } else {
                        print("Item not found in collection with ID \(collectionId) and URL \(infoData.url).")
                    }
                } catch {
                    print("Error removing from collection!")
                    print("\(error)")
                }
            },
            removeCollection: { collectionId, moduleId in
                let fetchRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "uuid == %@", collectionId)

                do {
                    // Fetch the collection
                    let collections = try context.fetch(fetchRequest)
                    
                    if let collection = collections.first {
                        // Delete the items associated with the collection
                        if let items = collection.items as? Set<Item> { // Assuming a one-to-many relationship
                            for item in items {
                                context.delete(item)
                            }
                        }
                        
                        // Delete the collection itself
                        context.delete(collection)
                        
                        // Save the context to persist the changes
                        try context.save()
                        print("Successfully deleted collection and associated items for collectionId: \(collectionId)")
                    } else {
                        print("Collection not found with ID: \(collectionId)")
                    }
                } catch {
                    print("Error deleting collection!")
                    print("\(error)")
                }
            },
            clearCollection: { collectionId in
                let fetchRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()

                do {
                    // Fetch the collection
                    let items = try context.fetch(fetchRequest)
                    
                    for item in items {
                        context.delete(item)
                    }
                    
                    try context.save()
                    print("Successfully deleted associated items for collectionId: \(collectionId)")
                } catch {
                    print("Error deleting collection!")
                    print("\(error)")
                }
            },
            fetchContinueWatching: {
                let randomId = UUID().uuidString
                var result = HomeSection(id: randomId, title: "Continue Watching", type: 3, list: [])
                
                // Create a fetch request for the ContinueWatching entity
                let fetchRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()
                
                do {
                    // Fetch all continue watching items
                    let continueWatchingItems = try context.fetch(fetchRequest)
                    print("Found \(continueWatchingItems.count) continue watching items")
                    
                    // Dictionary to track processed items by their content URL to avoid duplicates
                    var processedItems = [String: Bool]()

                    for item in continueWatchingItems {
                        // Parse each item to create HomeData object
                        guard let moduleId = item.moduleId,
                              let infoDataString = item.infoData,
                              let episodeDataString = item.episodeData else {
                            print("Skipping item due to missing data")
                            continue
                        }
                        
                        do {
                            // Decode the stored data carefully
                            let infoData = try JSONDecoder().decode(InfoData.self, from: infoDataString)
                            let mediaData = try JSONDecoder().decode(MediaItem.self, from: episodeDataString)
                            
                            // Create a content key to detect duplicates
                            let contentKey = infoData.url + "-" + mediaData.url
                            
                            // Skip if we've already processed this item
                            if processedItems[contentKey] != nil {
                                print("Skipping duplicate item: \(infoData.titles.primary) - \(mediaData.title ?? "Episode")")
                                continue
                            }
                            
                            // Mark this item as processed
                            processedItems[contentKey] = true
                            
                            // Ensure we have valid progress and duration values
                            let progress = max(0, min(item.progress, item.duration))
                            let duration = max(1.0, item.duration) // Ensure duration is at least 1 second
                            
                            // Debug log for progress tracking
                            print("Item: \(infoData.titles.primary) - Progress: \(progress)/\(duration)")
                            
                            // Format the progress/duration as a string indicator
                            let progressTime = formatTimeSeconds(progress)
                            let durationTime = formatTimeSeconds(duration)
                            let timeIndicator = "\(progressTime) / \(durationTime)"
                            
                            // Ensure we have a valid thumbnail
                            let posterUrl = mediaData.thumbnail ?? infoData.poster
                            
                            // Create HomeData with truly unique ID
                            let homeData = HomeData(
                                id: UUID().uuidString, // Use a fresh UUID for guaranteed uniqueness
                                url: infoData.url,
                                titles: Titles(primary: infoData.titles.primary, secondary: mediaData.title ?? "Episode \(mediaData.number.removeTrailingZeros())"),
                                description: infoData.description,
                                poster: posterUrl,
                                label: Label(text: "Resume", color: ""),
                                indicator: timeIndicator,
                                status: ItemStatus.inprogress,
                                current: Int(progress), // Convert to Int
                                total: Int(duration)    // Convert to Int
                            )
                            result.list.append(homeData)
                        } catch {
                            print("Error decoding item data: \(error)")
                            continue
                        }
                    }
                } catch {
                    print("Error fetching continue watching: \(error)")
                    
                    // Return an empty section on error
                    return HomeSection(id: randomId, title: "Continue Watching", type: 0, list: [])
                }

                return result
            },
            addToContinueWatching: { moduleId, collectionItem, progress, duration in
                // Validate inputs to prevent nil values
                guard moduleId != nil && !moduleId.isEmpty,
                      duration > 0 else {
                    print("Invalid input parameters for addToContinueWatching")
                    return
                }
                
                // Check if media data exists
                guard let mediaData = collectionItem.mediaData else {
                    print("Warning: Missing media data for continue watching, cannot save")
                    return
                }
                
                // Log progress data for debugging
                print("Adding to continue watching: moduleId=\(moduleId), progress=\(progress), duration=\(duration)")
                
                // Use a dedicated context for this operation to avoid threading issues
                let taskContext = persistentContainer.newBackgroundContext()
                taskContext.performAndWait {
                    // First check if this episode already exists in continue watching
                    let fetchRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()
                    
                    // Create a predicate to find exact matches
                    fetchRequest.predicate = NSPredicate(format: "moduleId == %@", moduleId)
                    
                    var existingItem: UserContinueWatching? = nil
                    var duplicates: [UserContinueWatching] = []
                    
                    do {
                        // Fetch all items for the module
                        let items = try taskContext.fetch(fetchRequest)
                        print("Found \(items.count) items for moduleId: \(moduleId)")
                        
                        // Prepare info and media data once for comparison
                        let infoData = collectionItem.infoData
                        let encodedInfoData = try? JSONEncoder().encode(infoData)
                        let encodedMediaData = try? JSONEncoder().encode(mediaData)
                        
                        // Skip if we couldn't encode the data
                        guard let encodedInfoData = encodedInfoData,
                              let encodedMediaData = encodedMediaData else {
                            print("Failed to encode data for continue watching")
                            return
                        }
                        
                        // Find matching items
                        for item in items {
                            if let itemInfoDataString = item.infoData,
                               let itemEpisodeDataString = item.episodeData {
                                do {
                                    let itemInfoData = try JSONDecoder().decode(InfoData.self, from: itemInfoDataString)
                                    let itemMediaData = try JSONDecoder().decode(MediaItem.self, from: itemEpisodeDataString)
                                    
                                    let infoUrlsMatch = itemInfoData.url == infoData.url
                                    let mediaUrlsMatch = itemMediaData.url == mediaData.url
                                    
                                    if infoUrlsMatch && mediaUrlsMatch {
                                        if existingItem == nil {
                                            existingItem = item
                                            print("Found primary match for: \(itemInfoData.titles.primary)")
                                        } else {
                                            duplicates.append(item)
                                            print("Found duplicate to remove: \(itemInfoData.titles.primary)")
                                        }
                                    }
                                } catch {
                                    print("Error decoding item data: \(error)")
                                    continue
                                }
                            }
                        }
                        
                        // Calculate reasonable progress value
                        let validProgress = max(0, min(progress, duration))
                        let validDuration = max(1.0, duration) // Ensure duration is never zero
                        
                        // Remove duplicates if any were found
                        for duplicate in duplicates {
                            taskContext.delete(duplicate)
                        }
                        
                        // Update or create entry
                        if let existingItem = existingItem {
                            // Update existing item
                            existingItem.progress = validProgress
                            existingItem.duration = validDuration
                            existingItem.infoData = encodedInfoData
                            existingItem.episodeData = encodedMediaData
                            
                            print("Updated continue watching entry with progress: \(validProgress)/\(validDuration)")
                        } else {
                            // Create a new entry
                            let continueWatching = UserContinueWatching(context: taskContext)
                            continueWatching.moduleId = moduleId
                            continueWatching.uuid = UUID().uuidString
                            continueWatching.progress = validProgress
                            continueWatching.duration = validDuration
                            continueWatching.infoData = encodedInfoData
                            continueWatching.episodeData = encodedMediaData
                            
                            print("Created new continue watching entry with progress: \(validProgress)/\(validDuration)")
                        }
                        
                        // Save changes
                        if taskContext.hasChanges {
                            try taskContext.save()
                            print("Successfully saved continue watching data")
                        }
                    } catch {
                        print("Error managing continue watching entries: \(error)")
                    }
                }
            },
            removeFromContinueWatching: { moduleId, url in
                // Validate inputs
                guard moduleId != nil && !moduleId.isEmpty, !url.isEmpty else {
                    print("Invalid parameters for removeFromContinueWatching")
                    return
                }
                
                // Use a dedicated context for this operation
                let taskContext = persistentContainer.newBackgroundContext()
                taskContext.performAndWait {
                    let fetchRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "moduleId == %@", moduleId)
                    
                    do {
                        // Fetch all items for the module
                        let items = try taskContext.fetch(fetchRequest)
                        print("Checking \(items.count) items to find completed episode to remove")
                        
                        var itemsToRemove: [UserContinueWatching] = []
                        
                        for item in items {
                            if let infoDataString = item.infoData {
                                do {
                                    // Decode to check if the URL matches
                                    let infoData = try JSONDecoder().decode(InfoData.self, from: infoDataString)
                                    if infoData.url == url {
                                        // Mark for removal if URL matches
                                        itemsToRemove.append(item)
                                        print("Marked episode for removal: \(infoData.titles.primary) with URL: \(url)")
                                    }
                                } catch {
                                    print("Error decoding infoData during removal: \(error)")
                                    continue
                                }
                            }
                        }
                        
                        // Delete all matched items
                        for item in itemsToRemove {
                            taskContext.delete(item)
                            print("Removed completed episode from continue watching")
                        }
                        
                        // Save context to persist changes
                        if !itemsToRemove.isEmpty {
                            try taskContext.save()
                            print("Successfully removed \(itemsToRemove.count) completed episodes from continue watching")
                        } else {
                            print("No matching episodes found to remove for URL: \(url)")
                        }
                    } catch {
                        print("Error removing from continue watching: \(error)")
                    }
                }
            },
            cleanupDuplicateContinueWatching: {
                // Use a dedicated context for this operation
                let taskContext = persistentContainer.newBackgroundContext()
                taskContext.performAndWait {
                    let fetchRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()
                    
                    do {
                        // Fetch all continue watching items
                        let items = try taskContext.fetch(fetchRequest)
                        print("Found \(items.count) continue watching items to check for duplicates")
                        
                        // Dictionary to track unique content by URL pairs
                        var contentMap: [String: UserContinueWatching] = [:]
                        var duplicatesToRemove: [UserContinueWatching] = []
                        
                        // Identify duplicates based on content keys
                        for item in items {
                            if let infoDataString = item.infoData,
                               let episodeDataString = item.episodeData {
                                do {
                                    let infoData = try JSONDecoder().decode(InfoData.self, from: infoDataString)
                                    let mediaData = try JSONDecoder().decode(MediaItem.self, from: episodeDataString)
                                    
                                    // Create a unique content key
                                    let contentKey = infoData.url + "-" + mediaData.url
                                    
                                    if let existingItem = contentMap[contentKey] {
                                        // Found duplicate - keep the one with the latest progress
                                        if item.progress > existingItem.progress {
                                            // This item has more progress, so keep it and mark the existing one as duplicate
                                            duplicatesToRemove.append(existingItem)
                                            contentMap[contentKey] = item
                                        } else {
                                            // The existing item has more progress, so mark this one as duplicate
                                            duplicatesToRemove.append(item)
                                        }
                                    } else {
                                        // First time seeing this content, add to map
                                        contentMap[contentKey] = item
                                    }
                                } catch {
                                    print("Error decoding data during cleanup: \(error)")
                                    continue
                                }
                            }
                        }
                        
                        // Remove all identified duplicates
                        if !duplicatesToRemove.isEmpty {
                            for duplicate in duplicatesToRemove {
                                taskContext.delete(duplicate)
                            }
                            
                            try taskContext.save()
                            print("Successfully removed \(duplicatesToRemove.count) duplicate continue watching entries")
                        } else {
                            print("No duplicate entries found")
                        }
                    } catch {
                        print("Error cleaning up duplicate continue watching entries: \(error)")
                    }
                }
            }
        )
    }()
}
