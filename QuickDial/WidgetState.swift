//
//  WidgetState.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 8/31/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct WidgetState: Equatable {
    static func == (lhs: WidgetState, rhs: WidgetState) -> Bool {
        return lhs.actions?.count == rhs.actions?.count
    }
    
    @DocDirectoryBacked<[Action]>(location: .storeLocation) private var _actions
    var actions: [Action]? {
        didSet {
            _actions = actions
        }
    }
    
    var actionsToDisplay: [Action] {
        if let unwrappedActions = _actions {
            var actionsToReturn = unwrappedActions
            actionsToReturn.append(Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil))
            return actionsToReturn
        } else {
            return [Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil)]
        }
    }
}

struct WidgetAction: Equatable { }

struct WidgetEnvironment {}

let widgetReducer = Reducer<WidgetState, WidgetAction, WidgetEnvironment> { state, action , env in
    return .none
}

