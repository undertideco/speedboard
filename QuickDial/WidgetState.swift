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
import Dependencies

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


struct WidgetReducer: Reducer {
    typealias State = WidgetState
    typealias Action = WidgetAction
    
    @Dependency(\.storageClient) var storageClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .initialLoad:
                return storageClient.getActions()
                    .map { actions in WidgetAction.actionLoadResponse(.success(actions)) }
            case let .actionLoadResponse(.success(actions)):
                state.actions = actions
                return .none
            case .actionLoadResponse(.failure(_)):
                state.actions = []
                return .none
            }
        }
    }
}