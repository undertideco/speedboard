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
import Dependencies

enum PersistenceError: Error {
    case unableToRead
    case unableToWrite
}

struct StorageClient {
    let containerPath: URL?
    
    var getActions: () -> Effect<[Action]>
    var saveAction: (Action) -> Effect<Action>
    var updateWidgetPreferences: (Action) -> Effect<Action>
    var deleteAction: (Action) -> Effect<Action>
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
                    
                    return .send(contactList.map { $0.action })
                } else {
                    return .send([])
                }
            } catch {
                print("Could not read contact fetcher")
                return .send([])
            }

        },
        saveAction: { action in
            let helper = CoreDataHelper(env: .live)
            
            guard let newAction = NSEntityDescription.insertNewObject(
                        forEntityName: "SavedAction",
                        into: helper.context) as? SavedAction else {
                return .send(action)
            }
            
            newAction.action = action
            
            do {
                try helper.context.save()
                return .send(action)
            } catch {
                return .send(action)
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
                        return .send(savedAction.action)
                    } catch {
                        return .run { send in
                    throw PersistenceError.unableToWrite
                }
                    }
                } else {
                    return .send(action)
                }
            } catch {
                return .send(action)
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
                return .send(action)
            } catch {
                return .send(action)
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
                    return .send(contactList.map { $0.action })
                } else {
                    return .send([])
                }
            } catch {
                print("Could not read contact fetcher")
                return .send([])
            }

        },
        saveAction: { action in
            let helper = CoreDataHelper(env: .mock)
            
            guard let newAction = NSEntityDescription.insertNewObject(
                        forEntityName: "SavedAction",
                        into: helper.context) as? SavedAction else {
                return .send(action)
            }
            
            newAction.action = action
            
            do {
                try helper.context.save()
                return .send(action)
            } catch {
                return .send(action)
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
                        return .send(savedAction.action)
                    } catch {
                        return .run { send in
                    throw PersistenceError.unableToWrite
                }
                    }
                } else {
                    return .send(action)
                }
            } catch {
                return .send(action)
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
                return .send(action)
            } catch {
                return .send(action)
            }
        }
    )
}

// MARK: - Dependency Key
private enum StorageClientKey: DependencyKey {
    static let liveValue = StorageClient.live
    static let testValue = StorageClient.mock
    static let previewValue = StorageClient.mock
}

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClientKey.self] }
        set { self[StorageClientKey.self] = newValue }
    }
}
