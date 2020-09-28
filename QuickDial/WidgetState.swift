//
//  WidgetState.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 8/31/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import ComposableArchitecture
import WidgetKit
import Combine

struct WidgetState: Equatable {
    static func == (lhs: WidgetState, rhs: WidgetState) -> Bool {
        return lhs.actions?.count == rhs.actions?.count
    }
    
    var actions: [Action]?
}

enum WidgetAction: Equatable {
    case initialLoad
    case actionLoadResponse(Result<[Action], PersistenceError>)
    case configLoadResponse(Result<WidgetConfig, FileReadError>)
}

struct WidgetEnvironment {
    let family: WidgetFamily
    let storageClient: StorageClient
    
    var fetchActions: ([Action]) -> Effect<WidgetConfig, FileReadError> {
        var selectedIdsDir: URL
        switch family {
        case .systemMedium:
            selectedIdsDir = .urlInDocumentsDirectory(with: .mediumWidgetActions)
        case .systemLarge:
            selectedIdsDir = .urlInDocumentsDirectory(with: .largeWidgetActions)
        default:
            return { _ in
                Effect(error: FileReadError())
            }
        }
        
        do {
            let selectedIdsData = try Data(contentsOf: selectedIdsDir)
            let selectedIds = try JSONDecoder().decode([String].self, from: selectedIdsData)
            
            return { actions in
                Effect(value: WidgetConfig(
                            actions: actions,
                            selectedActionIds: selectedIds
                    ))
            }
        } catch {
            return { _ in
                Effect(error: FileReadError())
            }
        }
    }
}

let widgetReducer = Reducer<WidgetState, WidgetAction, WidgetEnvironment> { state, action , env in
    switch action {
    case .initialLoad:
        return env.storageClient.getActions()
            .catchToEffect()
            .map(WidgetAction.actionLoadResponse)
            .eraseToEffect()
    case let .actionLoadResponse(.success(actions)):
        return env.fetchActions(actions)
            .catchToEffect()
            .map(WidgetAction.configLoadResponse)
            .eraseToEffect()
    case let .configLoadResponse(.success(config)):
        state.actions = config.actions
        return .none
    case .configLoadResponse(.failure(_)):
        state.actions = []
        return .none
    case .actionLoadResponse(.failure(_)):
        state.actions = []
        return .none
    }
}

