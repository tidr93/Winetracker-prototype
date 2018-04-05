//
//  CoreDataStack.swift
//  ToDoing
//
//  Created by Samuel Benoit on 2018-03-24.
//  Copyright © 2018 comp3097. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Wines")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print(">>> Error: \(error!)")
                return
            }
        }
        
        return container
        
    }
    
    
    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }
}
