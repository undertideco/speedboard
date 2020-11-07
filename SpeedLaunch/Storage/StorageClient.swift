//
//  StorageClient.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/25/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import ComposableArchitecture
import Foundation
import CoreData

enum PersistenceError: Error {
    case unableToRead
    case unableToWrite
}

struct StorageClient {
    let containerPath: URL?
    
    var getActions: () -> Effect<[Action], PersistenceError>
    var saveAction: (Action) -> Effect<Action, PersistenceError>
    var updateWidgetPreferences: (Action) -> Effect<Action, PersistenceError>
    var deleteAction: (Action) -> Effect<Action, PersistenceError>
}

extension StorageClient {
    static let live = StorageClient(
        containerPath: CoreDataStack.containerModelPath,
        getActions: {
            let helper = CoreDataHelper(env: .live)
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAction")
            
            do {
                if let contactList = try helper.context.fetch(fr) as? [SavedAction] {
                    #if DEBUG
                    if CommandLine.arguments.contains("--backup-model") {
                        helper.backupToDocDir()
                    }
                    #endif
                    
                    return Effect(value: contactList.map { $0.action })
                } else {
                    return Effect(error: PersistenceError.unableToRead)
                }
            } catch {
                print("Could not read contact fetcher")
                return Effect(error: PersistenceError.unableToRead)
            }

        },
        saveAction: { action in
            let helper = CoreDataHelper(env: .live)
            
            guard let newAction = NSEntityDescription.insertNewObject(
                        forEntityName: "SavedAction",
                        into: helper.context) as? SavedAction else {
                return Effect(error: PersistenceError.unableToWrite)
            }
            
            newAction.action = action
            
            do {
                try helper.context.save()
                return Effect(value: action)
            } catch {
                return Effect(error: PersistenceError.unableToWrite)
            }
        },
        updateWidgetPreferences: { action in
            let helper = CoreDataHelper(env: .live)

            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAction")
            fr.predicate = NSPredicate(format: "%K == %@", "id", action.id as CVarArg)
            
            do {
                if let actions = try helper.context.fetch(fr) as? [SavedAction],
                   let savedAction = actions.first {
                    
                    savedAction.setValue(action.isMediumWidgetDisplayable, forKey: "isMediumWidgetDisplayable")
                    savedAction.setValue(action.isLargeWidgetDisplayable, forKey: "isLargeWidgetDisplayable")
                    
                    do {
                        try helper.context.save()
                        return Effect(value: savedAction.action)
                    } catch {
                        return Effect(error: PersistenceError.unableToWrite)
                    }
                } else {
                    return Effect(error: PersistenceError.unableToRead)
                }
            } catch {
                return Effect(error: PersistenceError.unableToRead)
            }
        },
        deleteAction: { action in
            let helper = CoreDataHelper(env: .live)
            
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAction")
            fr.predicate = NSPredicate(format: "id == %@", action.id.uuidString)
            
            do {
                if let actions = try helper.context.fetch(fr) as? [SavedAction],
                   let action = actions.first {
                    helper.context.delete(action)
                    try helper.context.save()
                }
                return Effect(value: action)
            } catch {
                return Effect(error: PersistenceError.unableToWrite)
            }
        }
    )
    
    static let mock = StorageClient(
        containerPath: CoreDataStack.mockContainerPath,
        getActions: {
            let helper = CoreDataHelper(env: .mock)

            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAction")
            
            do {
                if let contactList = try helper.context.fetch(fr) as? [SavedAction] {
                    return Effect(value: contactList.map { $0.action })
                } else {
                    return Effect(error: PersistenceError.unableToRead)
                }
            } catch {
                print("Could not read contact fetcher")
                return Effect(error: PersistenceError.unableToRead)
            }

        },
        saveAction: { action in
            let helper = CoreDataHelper(env: .mock)
            
            guard let newAction = NSEntityDescription.insertNewObject(
                        forEntityName: "SavedAction",
                        into: helper.context) as? SavedAction else {
                return Effect(error: PersistenceError.unableToWrite)
            }
            
            newAction.action = action
            
            do {
                try helper.context.save()
                return Effect(value: action)
            } catch {
                return Effect(error: PersistenceError.unableToWrite)
            }
        },
        updateWidgetPreferences: { action in
            let helper = CoreDataHelper(env: .mock)

            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAction")
            fr.predicate = NSPredicate(format: "%K == %@", "id", action.id as CVarArg)
            
            do {
                if let actions = try helper.context.fetch(fr) as? [SavedAction],
                   let savedAction = actions.first {
                    
                    savedAction.setValue(action.isMediumWidgetDisplayable, forKey: "isMediumWidgetDisplayable")
                    savedAction.setValue(action.isLargeWidgetDisplayable, forKey: "isLargeWidgetDisplayable")
                    
                    do {
                        try helper.context.save()
                        return Effect(value: savedAction.action)
                    } catch {
                        return Effect(error: PersistenceError.unableToWrite)
                    }
                } else {
                    return Effect(error: PersistenceError.unableToRead)
                }
            } catch {
                return Effect(error: PersistenceError.unableToRead)
            }
        },
        deleteAction: { action in
            let helper = CoreDataHelper(env: .mock)
            
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedAction")
            fr.predicate = NSPredicate(format: "id == %@", action.id.uuidString)
            
            do {
                if let actions = try helper.context.fetch(fr) as? [SavedAction],
                   let action = actions.first {
                    helper.context.delete(action)
                    try helper.context.save()
                }
                return Effect(value: action)
            } catch {
                return Effect(error: PersistenceError.unableToWrite)
            }
        }
    )
}
