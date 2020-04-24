//
//  Action.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct Action: Codable {
    let type: ActionType
    let position: IndexPath
    let phoneNumber: String
    let image: Data
}
