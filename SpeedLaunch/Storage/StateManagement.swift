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
            lhs.isContactPickerOpen == rhs.isContactPickerOpen
    }
    
    @DocDirectoryBacked<[String]>(location: .largeWidgetActions) var largeWidgetActions
    @DocDirectoryBacked<[String]>(location: .mediumWidgetActions) var mediumWidgetActions
    
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
    var widgetConfigurationState: WidgetConfigurationState = WidgetConfigurationState( selectedIds: [])
    
}

struct AppEnvironment {
    let helper = CoreDataHelper()
    
    var storageClient: StorageClient
}

enum AppAction: Equatable {
    case initialLoad
    case addAction(ActionType, String, Int, String, Data)
    case deleteAction(Action)
    case setPicker(Bool)
    case widgetConfiguration(WidgetConfigurationAction)
    
    case didWriteActions(Result<Action, PersistenceError>)
    case didLoadActions(Result<[Action], PersistenceError>)
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
        
    case .addAction(let type, let name, let position, let number, let imageData):
        let action = Action(
            id: UUID(),
            type: type,
            contactValue: number,
            imageData: imageData,
            createdTime: Date(),
            actionName: name
        )
        
        return env.storageClient.saveAction(action)
            .catchToEffect()
            .map(AppAction.didWriteActions)
            .eraseToEffect()
        
    case .deleteAction(let action):
        let actionId = action.id
        
        state.mediumWidgetActions = state.mediumWidgetActions?.filter { $0 != actionId.uuidString }
        state.largeWidgetActions = state.largeWidgetActions?.filter { $0 != actionId.uuidString }

        return env.storageClient.deleteAction(action)
            .catchToEffect()
            .map(AppAction.didWriteActions)
            .eraseToEffect()
    case .setPicker(let isPresented):
        state.isContactPickerOpen = isPresented
        return .none
    case .widgetConfiguration(_):
        return .none
    case .didWriteActions(_):
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        return Effect(value: AppAction.initialLoad)
            .eraseToEffect()
    case let .didLoadActions(.success(actions)):
        state.actions = actions
        
        return .none
    case .didLoadActions(.failure(_)):
        return .none
    }
    },
    widgetConfigReducer.pullback(
        state: \.widgetConfigurationState,
        action: /AppAction.widgetConfiguration,
        environment: { _ in WidgetConfigurationEnvironment() }
    )
)
