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
    case actionLoadResponse(Result<WidgetConfig, FileReadError>)
}

struct WidgetEnvironment {
    let family: WidgetFamily
    
    var fetchActions: () -> Effect<WidgetConfig, FileReadError> {
        let actionsDir: URL = .urlInDocumentsDirectory(with: .storeLocation)
        var selectedIdsDir: URL
        
        switch family {
        case .systemMedium:
            selectedIdsDir = .urlInDocumentsDirectory(with: .mediumWidgetActions)
        case .systemLarge:
            selectedIdsDir = .urlInDocumentsDirectory(with: .largeWidgetActions)
        default:
            return {
                Effect(error: FileReadError())
            }
        }
        
        do {
            let actionsData = try Data(contentsOf: actionsDir)
            let selectedIdsData = try Data(contentsOf: selectedIdsDir)
            
            let actions = try JSONDecoder().decode([Action].self, from: actionsData)
            let selectedIds = try JSONDecoder().decode([String].self, from: selectedIdsData)
            
            return {
                Effect(value: WidgetConfig(
                        actions: actions,
                        selectedActionIds: selectedIds
                ))
            }
        } catch {
            return {
                Effect(error: FileReadError())
            }
        }
    }
}

let widgetReducer = Reducer<WidgetState, WidgetAction, WidgetEnvironment> { state, action , env in
    switch action {
    case .initialLoad:
        return env.fetchActions()
            .catchToEffect()
            .map(WidgetAction.actionLoadResponse)
            .eraseToEffect()
    case let .actionLoadResponse(.success(config)):
        state.actions = config.actions.filter {
            config.selectedActionIds.contains($0.id)
        }
        return .none
    case .actionLoadResponse(.failure(_)):
        state.actions = []
        return .none
    }
}

