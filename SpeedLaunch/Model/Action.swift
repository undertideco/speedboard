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
    let imageUrl: URL?
    
    func generateURLLaunchSchemeString() -> URL? {
        let phoneNumberKit = PhoneNumberKit()
        
        guard let phoneNumber = phoneNumber else { return nil }
        let parsedNumber = try! phoneNumberKit.parse(phoneNumber, ignoreType: true)
        var actionComponents = URLComponents(string: phoneNumberKit.format(parsedNumber, toType: .e164))!
        
        switch type {
        case .message:
            actionComponents.scheme = "sms"
        case .call:
            actionComponents.scheme = "tel"
        case .facetime:
            actionComponents.scheme = "facetime"
        default:
            break
        }
        
        var wrappedComponents = URLComponents()
        wrappedComponents.scheme = "speedboard"
        wrappedComponents.path = "/open"
        wrappedComponents.queryItems = [
            URLQueryItem(name: "url", value: "\(actionComponents.url!.absoluteString)")
        ]
        
        return wrappedComponents.url
    }
}

extension Action: Identifiable {
    public var id: String { "\(self.position) - \(self.phoneNumber ?? "")" }
}
