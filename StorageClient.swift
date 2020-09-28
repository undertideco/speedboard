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
    var getActions: () -> Effect<[Action], PersistenceError>
    var saveAction: (Action) -> Effect<Action, PersistenceError>
    var deleteAction: (Action) -> Effect<Action, PersistenceError>
}

extension StorageClient {
    static let live = StorageClient(
        getActions: {
            let helper = CoreDataHelper()
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
            let helper = CoreDataHelper()

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
        deleteAction: { action in
            let helper = CoreDataHelper()
            
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
