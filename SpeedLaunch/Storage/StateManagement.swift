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
            actionsToReturn.append(Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil))
            return actionsToReturn
        } else {
            return [Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil)]
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
    case addAction(ActionType, String, Int, String, Data)
    case deleteAction(Int)
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action , env in
    switch action {
    case .addAction(let type, let name, let position, let number, let imageData):
        let imageURL = URL.urlInDocumentsDirectory(with: "\(position).png")
        try! imageData.write(to: imageURL)
        
        let action = Action(type: type, position: position, phoneNumber: number, imageUrl: imageURL, actionName: name)
        
        if let _ = state.actions {
            state.actions!.append(action)
        } else {
            state.actions = [action]
        }
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: "co.undertide.speedboard")
        }
        
        return .none
    case .deleteAction(let index):
        print("remove action")
        guard let actionImageURL = state.actions?[index].imageUrl else { return .none }
        try? FileManager.default.removeItem(at: actionImageURL)
        state.actions?.remove(at: index)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: "co.undertide.speedboard")
        }
        return .none
    }
}
