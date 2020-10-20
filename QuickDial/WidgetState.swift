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
}

struct WidgetEnvironment {
    let family: WidgetFamily
    let storageClient: StorageClient
}

let widgetReducer = Reducer<WidgetState, WidgetAction, WidgetEnvironment> { state, action , env in
    switch action {
    case .initialLoad:
        return env.storageClient.getActions()
            .catchToEffect()
            .map(WidgetAction.actionLoadResponse)
            .eraseToEffect()
    case let .actionLoadResponse(.success(actions)):
        switch env.family {
        case .systemMedium:
            state.actions = actions.filter { $0.isMediumWidgetDisplayable }
        case .systemLarge:
            state.actions = actions.filter { $0.isLargeWidgetDisplayable }
        default:
            break
        }
        return .none
    case .actionLoadResponse(.failure(_)):
        state.actions = []
        return .none
    }
}

