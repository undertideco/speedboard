//
//  StateManagement.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 15/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import ComposableArchitecture
import WidgetKit
import CoreData
import Contacts

struct AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        return lhs.actions.count == rhs.actions.count &&
            lhs.isContactPickerOpen == rhs.isContactPickerOpen &&
            lhs.isEditing == rhs.isEditing
    }
    
    var actions: [Action] = []
    
    var actionsToDisplay: [Action] {
        if actions.count != 0 {
            var actionsToReturn = actions.sorted {
                $0.createdTime < $1.createdTime
            }
            actionsToReturn.append(
                Action(
                    id: UUID(),
                    type: .empty,
                    contactValue: nil,
                    imageData: nil,
                    createdTime: Date()
                )
            )
            return actionsToReturn
        } else {
            return [
                Action(
                    id: UUID(),
                    type: .empty,
                    contactValue: nil,
                    imageData: nil,
                    createdTime: Date()
                )
            ]
        }
    }
    
    var isContactPickerOpen: Bool = false
    var isEditing: Bool = false
    
    var configurationState = ConfigurationState()
}

struct AppEnvironment {
    var storageClient: StorageClient
}

enum AppAction: Equatable {
    case loadActions
    case deleteAction(Action)
    case setPicker(Bool)
    case setEditing(Bool)
    case widgetConfiguration(WidgetConfigurationAction)
    
    case didWriteActions(Result<Action, PersistenceError>)
    case didLoadActions(Result<[Action], PersistenceError>)
    
    case configurationView(ConfigurationAction)
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer { state, action , env in
    switch action {
    case .loadActions:
        return env.storageClient.getActions()
            .catchToEffect()
            .map(AppAction.didLoadActions)
            .eraseToEffect()
    case .deleteAction(let action):
        let actionId = action.id

        return env.storageClient.deleteAction(action)
            .catchToEffect()
            .map(AppAction.didWriteActions)
            .eraseToEffect()
    case .setPicker(let isPresented):
        state.isContactPickerOpen = isPresented
        return .none
    case .widgetConfiguration(_):
        return env.storageClient.getActions()
            .catchToEffect()
            .map(AppAction.didLoadActions)
            .eraseToEffect()
    case .didWriteActions(_):
        return Effect(value: AppAction.loadActions)
            .eraseToEffect()
    case let .didLoadActions(.success(actions)):
        var contacts: [String: CNContact] = [:]
        
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            do {
                let contactPredicate = CNContact.predicateForContacts(withIdentifiers: actions.compactMap{ $0.contactBookIdentifier })
                
                let keysToFetch = [CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey, CNContactIdentifierKey] as [CNKeyDescriptor]
                contacts = try CNContactStore().unifiedContacts(matching: contactPredicate, keysToFetch: keysToFetch).reduce(into: [String: CNContact]()){
                    $0[$1.identifier] = $1
                }
            } catch {
                state.actions = actions
                return .none
            }
        }
        
        state.actions = actions.map { action in
            guard let contactBookID = action.contactBookIdentifier else { return action }
            
            if let contactBookImageData = contacts[contactBookID]!.thumbnailImageData,
                contacts.keys.contains(contactBookID) && action.imageData != contactBookImageData {
                return Action(action: action, newImageData: contactBookImageData)
            }
            
            return action
        }
        return .none
    case .didLoadActions(.failure(_)):
        return .none
    case .setEditing(let isEditing):
        state.isEditing = isEditing
        return .none
    case .configurationView(.addAction):
        return Effect(value: AppAction.loadActions)
            .eraseToEffect()
    default:
        return .none
    }
    },
    widgetConfigReducer.pullback(
        state: \.actions,
        action: /AppAction.widgetConfiguration,
        environment: { _ in WidgetConfigurationEnvironment(storageClient: CommandLine.arguments.contains("--load-local") ? .mock : .live) }
    ),
    configurationReducer.pullback(
        state: \.configurationState,
        action: /AppAction.configurationView,
        environment: { _ in .init(storageClient: CommandLine.arguments.contains("--load-local") ? .mock : .live, contactBookClient: ContactBookClient.live) }
    )
)
