//
//  UserContinueWatching+CoreDataProperties.swift
//  Chouten
//
//  Created by Inumaki on 20/10/2024.
//
//

import Foundation
import CoreData


extension UserContinueWatching {

    @nonobjc  class func fetchRequest() -> NSFetchRequest<UserContinueWatching> {
        return NSFetchRequest<UserContinueWatching>(entityName: "UserContinueWatching")
    }

    @NSManaged  var episodeData: Data?
    @NSManaged  var infoData: Data?
    @NSManaged  var moduleId: String?
    @NSManaged  var uuid: String?

}

extension UserContinueWatching : Identifiable {

}
