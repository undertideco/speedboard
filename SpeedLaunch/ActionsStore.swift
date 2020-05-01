//
//  ActionsStore.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 22/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

final class ActionStore {
    static let changedNotification = Notification.Name("ActionStoreChanged")
    static private let documentDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let shared = ActionStore()
    
    let baseURL: URL?
    private(set) var actions: [Action]
    var actionsToDisplay: [Action?] {
        var includedActions: [Action?] = []
        for i in 0...8 {
            for action in actions {
                if action.position == i {
                    includedActions.append(action)
                }
            }
            if !actions.indices.contains(i) {
                includedActions.append(nil)
            }
        }
        
        return includedActions
    }
    
    init() {
        self.baseURL = ActionStore.documentDirectory
        
        
        if let u = baseURL,
            let data = try? Data(contentsOf: u.appendingPathComponent(.storeLocation)),
            let actions = try? JSONDecoder().decode([Action].self, from: data) {
            self.actions = actions
        } else {
            self.actions = []
        }
    }
    
    func save(_ action: Action) {
        self.actions.append(action)
        
        if let url = baseURL, let data = try? JSONEncoder().encode(actions) {
            try! data.write(to: url.appendingPathComponent(.storeLocation))
            // error handling ommitted
            print(url.appendingPathComponent(.storeLocation))
        }
        
        NotificationCenter.default.post(name: ActionStore.changedNotification, object: action, userInfo: nil)
    }
    
    func item(at index: Int) -> Action? {
        return self.actions[index]
    }
}

fileprivate extension String {
    static let storeLocation = "actions.json"
}
