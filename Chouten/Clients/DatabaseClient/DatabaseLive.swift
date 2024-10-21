//
//  Live.swift
//
//
//  Created by Eltik on 30.7.24.
//

import Foundation
import Dependencies
import CoreData

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
                        if let items = collection.items as? Set<Item> {
                            var data: [HomeData] = []
                            
                            for item in items {
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
                        if let items = collection.items as? Set<Item> {
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
                        let item = Item(context: context)
                        item.moduleId = moduleId
                        item.infoData = try? JSONEncoder().encode(infoData)
                        item.flag = 0 // infoData.flag.rawValue // Assuming flag is a string
                        
                        // Add the item to the collection's items set
                        // collection.addToItems(item)

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
                let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
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
                        // Update the properties
                        item.infoData = try? JSONEncoder().encode(infoData)
                        item.flag = 0 // infoData.flag.rawValue // Assuming flag is a string
                        
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
                let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
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
            fetchContinueWatching: {
                let randomId = UUID().uuidString
                var result = HomeSection(id: randomId, title: "Continue Watching", type: 3, list: [])
                
                return result
                /*

                // Create a fetch request for the ContinueWatching entity
                let fetchRequest: NSFetchRequest<ContinueWatching> = ContinueWatching.fetchRequest()
                
                do {
                    // Fetch all continue watching items
                    let continueWatchingItems = try context.fetch(fetchRequest)

                    for item in continueWatchingItems {
                        // Parse each item to create HomeData object
                        guard let moduleId = item.moduleId,
                              let infoDataString = item.infoData,
                              let episodeDataString = item.episodeData else {
                            continue
                        }
                        
                        do {
                            let itemData = try JSONDecoder().decode(CollectionItem.self, from: infoDataString.data(using: .utf8)!)
                            let homeData = HomeData(
                                url: itemData.url,
                                titles: Titles(primary: itemData.infoData.titles.primary, secondary: itemData.infoData.titles.secondary ?? ""),
                                description: itemData.infoData.description,
                                poster: itemData.infoData.poster,
                                label: Label(text: "Test", color: ""),
                                indicator: "\(itemData.flag.rawValue)",
                                status: itemData.flag,
                                current: nil,
                                total: nil
                            )
                            result.list.append(homeData)
                        } catch {
                            continue
                        }
                    }
                } catch {
                    print("Error fetching continue watching!")
                    print("\(error)")
                    
                    // Return an empty section on error
                    return HomeSection(id: randomId, title: "Continue Watching", type: 0, list: [])
                }

                return result
                 */
            },
            addToContinueWatching: { moduleId, infoData in
                // Create a new ContinueWatching instance
                let continueWatching = UserContinueWatching(context: context)

                // Assign values to the attributes
                continueWatching.moduleId = moduleId
                continueWatching.infoData = try? JSONEncoder().encode(infoData) // yourInfoData must be JSON serializable

                // Save the context
                do {
                    try context.save()
                    print("ContinueWatching entry initialized successfully!")
                } catch {
                    print("Error initializing ContinueWatching entry: \(error)")
                }
            }
        )
    }()
}
