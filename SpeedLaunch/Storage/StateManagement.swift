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
        return lhs.actions?.count == rhs.actions?.count &&
            lhs.isContactPickerOpen == rhs.isContactPickerOpen
    }
    
    @DocDirectoryBacked<[Int]>(location: .largeWidgetActions) var largeWidgetActions
    @DocDirectoryBacked<[Int]>(location: .mediumWidgetActions) var mediumWidgetActions
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
    
    var isContactPickerOpen: Bool = false
    var widgetConfigurationState: WidgetConfigurationState = WidgetConfigurationState(actions: [], selectedIndices: [])
    
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
    case setPicker(Bool)
    case widgetConfiguration(WidgetConfigurationAction)
}

let testReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer { state, action , env in
    switch action {
    case .addAction(let type, let name, let position, let number, let imageData):
        let imageURL = URL.urlInDocumentsDirectory(with: "\(UUID()).png")
        try! imageData.write(to: imageURL)
        
        let action = Action(type: type,
                            position: position,
                            phoneNumber: number,
                            imageUrl: imageURL,
                            actionName: name)
        
        if let _ = state.actions {
            state.actions!.append(action)
        } else {
            state.actions = [action]
        }

        return .none
    case .deleteAction(let index):
        print("remove action")
        guard let actionImageURL = state.actions?[index].imageUrl else { return .none }
        try? FileManager.default.removeItem(at: actionImageURL)
        
        state.actions?.remove(at: index)
        state.mediumWidgetActions = state.mediumWidgetActions?.filter { $0 != index }
        state.largeWidgetActions = state.largeWidgetActions?.filter { $0 != index }

        return .none
    case .setPicker(let isPresented):
        state.isContactPickerOpen = isPresented
        return .none
    case .widgetConfiguration(_):
        return .none
    }
    },
    widgetConfigReducer.pullback(
        state: \.widgetConfigurationState,
        action: /AppAction.widgetConfiguration,
        environment: { _ in WidgetConfigurationEnvironment() }
    )
)
