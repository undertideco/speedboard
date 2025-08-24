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
import Dependencies

struct AppState: Equatable {
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
    
    enum PresentingSheet: Identifiable {
        case settings, contacts
        
        var id: Int {
            hashValue
        }
    }
    
    var presenting: PresentingSheet? = nil
    var isEditing: Bool = false
    var isContactPickerOpen: Bool = false
    var selectedContact: CNContact? = nil
    
    var configurationState = ConfigurationState()
    var settingsState = SettingsViewState()
}


enum AppAction: Equatable {
    case loadActions
    case deleteAction(Action)
    case presentSettingsScreen
    case presentContactsConfigurator(CNContact)
    case setContactPickerPresentation(Bool)
    case setPresentingSheet(AppState.PresentingSheet?)
    case setEditing(Bool)
    case widgetConfiguration(WidgetConfigurationAction)
    
    case didWriteActions(Result<Action, PersistenceError>)
    case didLoadActions(Result<[Action], PersistenceError>)
    
    case configurationView(ConfigurationAction)
    case settingsView(SettingsViewAction)
}

struct AppReducer: Reducer {
    typealias State = AppState
    typealias Action = AppAction
    
    @Dependency(\.storageClient) var storageClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
        switch action {
        case .loadActions:
            return storageClient.getActions()
                .map { actions in AppAction.didLoadActions(.success(actions)) }
                
        case .deleteAction(let action):
            return storageClient.deleteAction(action)
                .map { deletedAction in AppAction.didWriteActions(.success(deletedAction)) }
                
        case .presentSettingsScreen:
            state.presenting = .settings
            return .none
            
        case let .presentContactsConfigurator(selectedContact):
            state.configurationState.selectedContact = selectedContact
            state.presenting = .contacts
            return .none
            
        case let .setPresentingSheet(sheetType):
            state.presenting = sheetType
            return .none
            
        case let .setContactPickerPresentation(isPresented):
            state.isContactPickerOpen = isPresented
            return .none
            
                
        case .didWriteActions(_):
            return .send(.loadActions)
                
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
                
                if let contactBookImageData = contacts[contactBookID]?.thumbnailImageData,
                    contacts.keys.contains(contactBookID) && action.imageData != contactBookImageData {
                    return SpeedLaunch.Action(action: action, newImageData: contactBookImageData)
                }
                
                return action
            }
            return .none
            
        case .didLoadActions(.failure(_)):
            return .none
            
        case .setEditing(let isEditing):
            state.isEditing = isEditing
            return .none
            
        case .configurationView(.didAddAction(.success(_))):
            state.presenting = nil
            state.selectedContact = nil
            return .send(.loadActions)
            
        case .configurationView(_):
            return .none
            
        case .settingsView(_):
            return .none
            
        case .widgetConfiguration(.didUpdateAction(.success(_))):
            return .send(.loadActions)
            
        case .widgetConfiguration(_):
            return .none
        }
        }
        
        
        Scope(state: \.configurationState, action: /AppAction.configurationView) {
            ConfigurationReducer()
        }
        Scope(state: \.settingsState, action: /AppAction.settingsView) {
            SettingsViewReducer()
        }
        Scope(state: \.actions, action: /AppAction.widgetConfiguration) {
            WidgetConfigReducer()
        }
    }
}
