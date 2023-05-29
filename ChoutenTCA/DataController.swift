//
//  DataController.swift
//  ChoutenTCA
//
//  Created by Inumaki on 25.05.23.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Info")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                //TODO: add UserInterface to show user that something went wrong
                print("CoreData failed to load: \(error.localizedDescription)")
            }
        }
    }
}
