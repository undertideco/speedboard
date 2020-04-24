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
    
    func generateURLLaunchSchemeString() -> URL {
        switch type {
        case .gallery:
            return URL(string: "photos-redirect://")!
        case .message:
            return URL(string: "sms://\(phoneNumber)")!
        case .call:
            return URL(string: "tel://\(phoneNumber)")!
        }
    }
}
