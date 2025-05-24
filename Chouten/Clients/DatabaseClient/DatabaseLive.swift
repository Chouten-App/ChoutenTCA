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
                                            total: nil,
                                            moduleId: nil
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
                    
                    // Dictionary to track processed items by module + series + episode to avoid true duplicates
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
                            
                            // Create a content key to detect true duplicates (same module, same series, same episode)
                            let contentKey = moduleId + "-" + infoData.url + "-" + mediaData.url
                            
                            // Skip if we've already processed this exact item
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
                                total: Int(duration),    // Convert to Int
                                moduleId: moduleId
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
            fetchContinueWatchingData: { url in
                // Create a fetch request for the ContinueWatching entity
                let fetchRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()
                
                do {
                    // Fetch all continue watching items
                    let continueWatchingItems = try context.fetch(fetchRequest)
                    
                    for item in continueWatchingItems {
                        // Parse each item to find the matching URL
                        guard let infoDataString = item.infoData,
                              let episodeDataString = item.episodeData else {
                            continue
                        }
                        
                        do {
                            // Decode the stored data
                            let infoData = try JSONDecoder().decode(InfoData.self, from: infoDataString)
                            let mediaData = try JSONDecoder().decode(MediaItem.self, from: episodeDataString)
                            
                            // Check if this is the item we're looking for
                            if infoData.url == url {
                                let progress = item.progress
                                let duration = item.duration
                                return (infoData, mediaData, progress, duration)
                            }
                        } catch {
                            print("Error decoding continue watching item: \(error)")
                            continue
                        }
                    }
                } catch {
                    print("Error fetching continue watching data: \(error)")
                }
                
                return nil
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
                        
                        // Find items from the same series - we only want to keep the latest episode per series per module
                        for item in items {
                            if let itemInfoDataString = item.infoData,
                               let itemEpisodeDataString = item.episodeData {
                                do {
                                    let itemInfoData = try JSONDecoder().decode(InfoData.self, from: itemInfoDataString)
                                    let itemMediaData = try JSONDecoder().decode(MediaItem.self, from: itemEpisodeDataString)
                                    
                                    // Use URL as primary identifier, fallback to title if URL is empty
                                    let currentSeriesId = infoData.url.isEmpty ? infoData.titles.primary : infoData.url
                                    let existingSeriesId = itemInfoData.url.isEmpty ? itemInfoData.titles.primary : itemInfoData.url
                                    
                                    let infoUrlsMatch = currentSeriesId == existingSeriesId
                                    let mediaUrlsMatch = itemMediaData.url == mediaData.url
                                    
                                    print("🔍 Comparing items:")
                                    print("  Current: \(infoData.titles.primary) - Episode \(mediaData.number.removeTrailingZeros()) (ID: \(currentSeriesId))")
                                    print("  Existing: \(itemInfoData.titles.primary) - Episode \(itemMediaData.number.removeTrailingZeros()) (ID: \(existingSeriesId))")
                                    print("  Series IDs match: \(infoUrlsMatch), Episodes match: \(mediaUrlsMatch)")
                                    
                                    if infoUrlsMatch {
                                        if mediaUrlsMatch {
                                            // Same series, same episode - this is an update to existing progress
                                            if existingItem == nil {
                                                existingItem = item
                                                print("✅ Found exact match for: \(itemInfoData.titles.primary) - \(itemMediaData.title ?? "Episode \(itemMediaData.number.removeTrailingZeros())")")
                                            } else {
                                                duplicates.append(item)
                                                print("🗑️ Found duplicate to remove: \(itemInfoData.titles.primary) - \(itemMediaData.title ?? "Episode \(itemMediaData.number.removeTrailingZeros())")")
                                            }
                                        } else {
                                            // Same series, different episode - remove old episode as we only want the latest per series
                                            duplicates.append(item)
                                            print("🔄 Found old episode from same series to remove: \(itemInfoData.titles.primary) - \(itemMediaData.title ?? "Episode \(itemMediaData.number.removeTrailingZeros())")")
                                        }
                                    } else {
                                        print("✨ Different series, keeping both: \(itemInfoData.titles.primary)")
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
                        
                        print("📊 Summary for moduleId \(moduleId):")
                        print("  Removed \(duplicates.count) old/duplicate episodes")
                        
                        // Update or create entry
                        if let existingItem = existingItem {
                            // Update existing item
                            existingItem.progress = validProgress
                            existingItem.duration = validDuration
                            existingItem.infoData = encodedInfoData
                            existingItem.episodeData = encodedMediaData
                            
                            print("🔄 Updated continue watching entry: \(infoData.titles.primary) - Episode \(mediaData.number.removeTrailingZeros()) with progress: \(validProgress)/\(validDuration)")
                        } else {
                            // Create a new entry
                            let continueWatching = UserContinueWatching(context: taskContext)
                            continueWatching.moduleId = moduleId
                            continueWatching.uuid = UUID().uuidString
                            continueWatching.progress = validProgress
                            continueWatching.duration = validDuration
                            continueWatching.infoData = encodedInfoData
                            continueWatching.episodeData = encodedMediaData
                            
                            print("✨ Created new continue watching entry: \(infoData.titles.primary) - Episode \(mediaData.number.removeTrailingZeros()) with progress: \(validProgress)/\(validDuration)")
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
                        
                        // Dictionary to track unique series by module + series URL (one episode per series per module)
                        var seriesMap: [String: UserContinueWatching] = [:]
                        var duplicatesToRemove: [UserContinueWatching] = []
                        
                        // Keep only the latest episode per series per module
                        for item in items {
                            if let infoDataString = item.infoData,
                               let episodeDataString = item.episodeData,
                               let moduleId = item.moduleId {
                                do {
                                    let infoData = try JSONDecoder().decode(InfoData.self, from: infoDataString)
                                    let mediaData = try JSONDecoder().decode(MediaItem.self, from: episodeDataString)
                                    
                                    // Use URL as primary identifier, fallback to title if URL is empty
                                    let seriesId = infoData.url.isEmpty ? infoData.titles.primary : infoData.url
                                    
                                    // Use module + series ID as the key (one episode per series per module)
                                    let seriesKey = moduleId + "-" + seriesId
                                    
                                    if let existingItem = seriesMap[seriesKey] {
                                        // Found another episode from the same series - keep the one with higher episode number or latest progress
                                        let existingEpisodeData = try JSONDecoder().decode(MediaItem.self, from: existingItem.episodeData!)
                                        
                                        // Prefer higher episode number, fallback to progress if episode numbers are the same
                                        let shouldKeepNewItem = mediaData.number > existingEpisodeData.number || 
                                                              (mediaData.number == existingEpisodeData.number && item.progress > existingItem.progress)
                                        
                                        if shouldKeepNewItem {
                                            // Keep the newer episode/progress and mark the existing one as duplicate
                                            duplicatesToRemove.append(existingItem)
                                            seriesMap[seriesKey] = item
                                            print("Keeping newer episode: \(infoData.titles.primary) - Episode \(mediaData.number.removeTrailingZeros())")
                                        } else {
                                            // Keep the existing item and mark this one as duplicate
                                            duplicatesToRemove.append(item)
                                            print("Keeping existing episode: \(infoData.titles.primary) - Episode \(existingEpisodeData.number.removeTrailingZeros())")
                                        }
                                    } else {
                                        // First episode from this series in this module, add to map
                                        seriesMap[seriesKey] = item
                                        print("First episode for series in module: \(infoData.titles.primary) - Episode \(mediaData.number.removeTrailingZeros())")
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
            },
            clearAllData: {
                // Use a dedicated context for this operation
                let taskContext = persistentContainer.newBackgroundContext()
                taskContext.performAndWait {
                    do {
                        // Delete all UserContinueWatching entries
                        let continueWatchingRequest: NSFetchRequest<UserContinueWatching> = UserContinueWatching.fetchRequest()
                        let continueWatchingItems = try taskContext.fetch(continueWatchingRequest)
                        print("Deleting \(continueWatchingItems.count) continue watching entries...")
                        
                        for item in continueWatchingItems {
                            taskContext.delete(item)
                        }
                        
                        // Delete all UserItem entries
                        let itemRequest: NSFetchRequest<UserItem> = UserItem.fetchRequest()
                        let items = try taskContext.fetch(itemRequest)
                        print("Deleting \(items.count) collection items...")
                        
                        for item in items {
                            taskContext.delete(item)
                        }
                        
                        // Delete all UserCollection entries
                        let collectionRequest: NSFetchRequest<UserCollection> = UserCollection.fetchRequest()
                        let collections = try taskContext.fetch(collectionRequest)
                        print("Deleting \(collections.count) collections...")
                        
                        for collection in collections {
                            taskContext.delete(collection)
                        }
                        
                        // Save all changes
                        if taskContext.hasChanges {
                            try taskContext.save()
                            print("Successfully cleared all database content:")
                            print("- \(continueWatchingItems.count) continue watching entries")
                            print("- \(items.count) collection items")
                            print("- \(collections.count) collections")
                        } else {
                            print("No data to clear - database was already empty")
                        }
                    } catch {
                        print("Error clearing all database content: \(error)")
                    }
                }
            }
        )
    }()
}
