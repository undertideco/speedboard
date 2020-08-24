//
//  StateManagement.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 15/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        return lhs.actions?.count == rhs.actions?.count
    }
    
    @DocDirectoryBacked<[Action]>(location: .storeLocation) var actions
    
    var actionsToDisplay: [Action] {
        if let unwrappedActions = actions {
            var actionsToReturn = unwrappedActions
            actionsToReturn.append(Action(type: .empty, position: 999, phoneNumber: nil, image: nil))
            return actionsToReturn
        } else {
            return [Action(type: .empty, position: 999, phoneNumber: nil, image: nil)]
        }
    }
}

struct AppEnvironment {}

enum AppAction: Equatable {
    case addAction(Action)
    case deleteAction(Int)
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action , env in
    switch action {
    case .addAction(let action):
        if let _ = state.actions {
            state.actions!.append(action)
        } else {
            state.actions = [action]
        }
        print("add action")
        return .none
    case .deleteAction(let index):
        print("remove action")
        state.actions?.remove(at: index)
        return .none
    }
}

fileprivate extension String {
    static let storeLocation = "actions.json"
}
