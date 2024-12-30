//
//  UserContinueWatching+CoreDataProperties.swift
//  Chouten
//
//  Created by Inumaki on 24/11/2024.
//
//

import Foundation
import CoreData


extension UserContinueWatching {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserContinueWatching> {
        return NSFetchRequest<UserContinueWatching>(entityName: "UserContinueWatching")
    }

    @NSManaged public var episodeData: Data?
    @NSManaged public var infoData: Data?
    @NSManaged public var moduleId: String?
    @NSManaged public var uuid: String?
    @NSManaged public var progress: Double
    @NSManaged public var duration: Double

}

extension UserContinueWatching : Identifiable {

}
