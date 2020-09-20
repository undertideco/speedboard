//
//  WidgetSize.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/17/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

enum WidgetSize: Int {
    case medium, large
    
    var maxNumberOfActions: Int {
        switch self {
        case .medium:
            return 6
        case .large:
            return 9
        }
    }
}
