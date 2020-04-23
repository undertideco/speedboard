//
//  ActionType.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

enum ActionType: CaseIterable {
    case gallery, message, call
    
    func stringValue() -> String {
        switch self {
        case .gallery:
            return "gallery"
        case .message:
            return "message"
        case .call:
            return "call"
        }
    }
}
