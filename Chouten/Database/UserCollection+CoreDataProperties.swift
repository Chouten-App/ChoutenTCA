//
//  UserCollection+CoreDataProperties.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//
//

import Foundation
import CoreData


extension UserCollection {

    @nonobjc  class func fetchRequest() -> NSFetchRequest<UserCollection> {
        return NSFetchRequest<UserCollection>(entityName: "UserCollection")
    }

    @NSManaged  var name: String?
    @NSManaged  var uuid: String?
    @NSManaged  var items: NSSet?

}

// MARK: Generated accessors for items
extension UserCollection {

    @objc(addItemsObject:)
    @NSManaged  func addToItems(_ value: UserItem)

    @objc(removeItemsObject:)
    @NSManaged  func removeFromItems(_ value: UserItem)

    @objc(addItems:)
    @NSManaged  func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged  func removeFromItems(_ values: NSSet)

}

extension UserCollection : Identifiable {

}
