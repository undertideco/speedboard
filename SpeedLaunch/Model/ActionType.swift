//
//  ActionType.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

enum ActionType: String, CaseIterable, Codable {
    case message, call, facetime, empty
    
    func localizedStringKey() -> String {
        switch self {
        case .message:
            return "Action_Message"
        case .call:
            return "Action_Call"
        case .facetime:
            return "Action_FaceTime"
        case .empty:
            return "LaunchCell_EmptyTitle"
        }
    }
}
