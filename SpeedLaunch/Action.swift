//
//  Action.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import PhoneNumberKit

struct Action: Codable, Equatable {
    let type: ActionType
    let position: Int
    let phoneNumber: String?
    let image: Data?
    
    func generateURLLaunchSchemeString() -> URL? {
        let phoneNumberKit = PhoneNumberKit()

        switch type {
        case .message:
            guard let phoneNumber = phoneNumber else { return nil }
            let parsedNumber = try! phoneNumberKit.parse(phoneNumber)
            var components = URLComponents(string: phoneNumberKit.format(parsedNumber, toType: .e164))!
            components.scheme = "sms"
            return components.url!
        case .call:
            guard let phoneNumber = phoneNumber else { return nil }
            let parsedNumber = try! phoneNumberKit.parse(phoneNumber)
            var components = URLComponents(string: phoneNumberKit.format(parsedNumber, toType: .e164))!
            components.scheme = "tel"
            return components.url!
        case .empty:
            return nil
        }
    }
}

extension Action: Identifiable {
    public var id: Int { self.position }
}
