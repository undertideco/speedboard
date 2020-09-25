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
    
    @DocDirectoryBacked<[String]>(location: .largeWidgetActions) var largeWidgetActions
    @DocDirectoryBacked<[String]>(location: .mediumWidgetActions) var mediumWidgetActions
    @DocDirectoryBacked<[Action]>(location: .storeLocation) private var _actions
    
    var actions: [Action]? {
        didSet {
            _actions = actions
        }
    }
    var actionsToDisplay: [Action] {
        if let unwrappedActions = actions {
            var actionsToReturn = unwrappedActions.sorted {
                $0.createdTime < $1.createdTime
            }
            actionsToReturn.append(
                Action(
                    type: .empty,
                    contactValue: nil,
                    imageUrl: nil,
                    createdTime: Date()
                )
            )
            return actionsToReturn
        } else {
            return [
                Action(
                    type: .empty,
                    contactValue: nil,
                    imageUrl: nil,
                    createdTime: Date()
                )
            ]
        }
    }
    
    var isContactPickerOpen: Bool = false
    var widgetConfigurationState: WidgetConfigurationState = WidgetConfigurationState( selectedIds: [])
    
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

struct AppEnvironment {
    func deleteImageWithURL(_ url: URL) {
        // we move the image to tmpDir and let the OS delete the image instead because `removeItem`
        // is not a synchronous operation
        try? FileManager.default.moveItem(at: url, to: URL(fileURLWithPath: NSTemporaryDirectory(),
                                                           isDirectory: true))
    }
}

enum AppAction: Equatable {
    case addAction(ActionType, String, Int, String, Data)
    case deleteAction(Action)
    case setPicker(Bool)
    case widgetConfiguration(WidgetConfigurationAction)
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    Reducer { state, action , env in
    switch action {
    case .addAction(let type, let name, let position, let number, let imageData):
        let imageURL = URL.urlInDocumentsDirectory(with: "\(UUID()).png")
        try! imageData.write(to: imageURL)
        
        let action = Action(
            type: type,
            contactValue: number,
            imageUrl: imageURL,
            createdTime: Date(),
            actionName: name
        )
        
        if let _ = state.actions {
            state.actions!.append(action)
        } else {
            state.actions = [action]
        }

        return .none
    case .deleteAction(let action):
        let actionId = action.id
        
        state.actions = state.actions?.filter { $0.id != actionId }
        state.mediumWidgetActions = state.mediumWidgetActions?.filter { $0 != actionId }
        state.largeWidgetActions = state.largeWidgetActions?.filter { $0 != actionId }

        guard let actionImageURL = action.imageUrl else { return .none }
        
        return .fireAndForget {
            env.deleteImageWithURL(actionImageURL)
        }
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
