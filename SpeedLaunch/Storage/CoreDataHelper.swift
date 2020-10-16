//
//  CoreDataHelper.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/25/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper {
    
    let stack = CoreDataStack(modelName: "ActionModel")!
    var context:NSManagedObjectContext
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            executeSearch()
        }
    }
    
    init() {
        context = stack.context
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}


extension CoreDataHelper {
    func backupToDocDir() {
        do {
            let backupFile = try stack.coordinator.backupPersistentStore(atIndex: 0)
            print("The backup is at \"\(backupFile.fileURL.path)\"")
            // Do something with backupFile.fileURL
            // Move it to a permanent location, send it to the cloud, etc.
            // ...
        } catch {
            print("Error backing up Core Data store: \(error)")
        }
    }
}

