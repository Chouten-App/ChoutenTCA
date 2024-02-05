//
//  DataController.swift
//  ChoutenApp
//
//  Created by Inumaki on 17.10.23.
//

import CoreData
import Foundation

class DataController: ObservableObject {
  let container = NSPersistentContainer(name: "Info")

  init() {
    container.loadPersistentStores { _, error in
      if let error {
        // TODO: add UserInterface to show user that something went wrong
        print("CoreData failed to load: \(error.localizedDescription)")
      }
    }
  }
}
