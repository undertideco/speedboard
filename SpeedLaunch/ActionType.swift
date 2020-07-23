//
//  ActionType.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation

enum ActionType: String, CaseIterable, Codable {
    case message, call, empty
}
