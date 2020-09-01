//
//  StateManagement.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 15/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import WidgetKit
import ComposableArchitecture

struct AppState: Equatable {
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        return lhs.actions?.count == rhs.actions?.count
    }
    
    @DocDirectoryBacked<[Action]>(location: .storeLocation) private var _actions
    var actions: [Action]? {
        didSet {
            _actions = actions
        }
    }
    
    var actionsToDisplay: [Action] {
        if let unwrappedActions = actions {
            var actionsToReturn = unwrappedActions
            actionsToReturn.append(Action(type: .empty, position: 999, phoneNumber: nil, image: nil))
            return actionsToReturn
        } else {
            return [Action(type: .empty, position: 999, phoneNumber: nil, image: nil)]
        }
    }
    
    init() {
        actions = _actions
    }
    
    #if DEBUG
    init(actionsFromURL: URL) {
        let data = try! Data(contentsOf: actionsFromURL)
        let actionToSet = try! JSONDecoder().decode([Action].self, from: data)
        actions = actionToSet
    }
    #endif
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
        WidgetCenter.shared.reloadAllTimelines()
        return .none
    case .deleteAction(let index):
        print("remove action")
        state.actions?.remove(at: index)
        WidgetCenter.shared.reloadAllTimelines()
        return .none
    }
}
