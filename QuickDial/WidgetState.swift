//
//  WidgetState.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 8/31/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import ComposableArchitecture
import Foundation
import Combine

struct WidgetState: Equatable {
    static func == (lhs: WidgetState, rhs: WidgetState) -> Bool {
        return lhs.actions?.count == rhs.actions?.count
    }
    
    var actions: [Action]?
    
    var actionsToDisplay: [Action] {
        if let unwrappedActions = actions {
            var actionsToReturn = unwrappedActions
            actionsToReturn.append(Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil))
            return actionsToReturn
        } else {
            return [Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil)]
        }
    }
}

enum WidgetAction: Equatable {
    case initialLoad
    case actionLoadResponse(Result<[Action], FileReadError>)
}

struct WidgetEnvironment {
    var fetchActions: () -> Effect<[Action], FileReadError> {
        let documentDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.undertide.speedboard")!
        
        let actionsDir = documentDirectory.appendingPathComponent("actions.json")
        
        
        do {
            let data = try Data(contentsOf: actionsDir)
            let actions = try JSONDecoder().decode([Action].self, from: data)
            return {
                Effect(value: actions)
            }
        } catch {
            return {
                Effect(error: FileReadError())
            }
        }
    }
}

struct FileReadError: Error, Equatable {}


let widgetReducer = Reducer<WidgetState, WidgetAction, WidgetEnvironment> { state, action , env in
    switch action {
    case .initialLoad:
        return env.fetchActions()
            .catchToEffect()
            .map(WidgetAction.actionLoadResponse)
            .eraseToEffect()
    case let .actionLoadResponse(.success(actions)):
        state.actions = actions
        return .none
    case .actionLoadResponse(.failure(_)):
        state.actions = []
        return .none
    }
}

