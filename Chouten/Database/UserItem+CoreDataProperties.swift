//
//  UserItem+CoreDataProperties.swift
//  Chouten
//
//  Created by Steph on 20/10/2024.
//
//

import Foundation
import CoreData


extension UserItem {

    @nonobjc  class func fetchRequest() -> NSFetchRequest<UserItem> {
        return NSFetchRequest<UserItem>(entityName: "UserItem")
    }

    @NSManaged  var flag: String?
    @NSManaged  var infoData: Data?
    @NSManaged  var moduleId: String?
    @NSManaged  var uuid: String?
    @NSManaged  var collection: UserCollection?

}

extension UserItem : Identifiable {

}
