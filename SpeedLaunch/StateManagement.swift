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
    let helper = CoreDataHelper()
    
    var storageClient: StorageClient
}

enum AppAction: Equatable {
    case initialLoad
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
    case .initialLoad:
        #if DEBUG
        if CommandLine.arguments.contains("--backup-model") {
            CoreDataHelper().backupToDocDir()
        }
        #endif
        
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
        return Effect(value: AppAction.initialLoad)
            .eraseToEffect()
    case let .didLoadActions(.success(actions)):
        state.actions = actions
        return .none
    case .didLoadActions(.failure(_)):
        return .none
    case .setEditing(let isEditing):
        state.isEditing = isEditing
        return .none
    case .configurationView(.addAction):
        return Effect(value: AppAction.initialLoad)
            .eraseToEffect()
    default:
        return .none
    }
    },
    widgetConfigReducer.pullback(
        state: \.actions,
        action: /AppAction.widgetConfiguration,
        environment: { _ in WidgetConfigurationEnvironment(storageClient: .live) }
    ),
    configurationReducer.pullback(
        state: \.configurationState,
        action: /AppAction.configurationView,
        environment: { _ in .init(storageClient: .live) }
    )
)
