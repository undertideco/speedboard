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
        
        switch type {
        case .message:
            guard let phoneNumber = phoneNumber else { return nil }
            let parsedNumber = try! phoneNumberKit.parse(phoneNumber, ignoreType: true)
            var actionComponents = URLComponents(string: phoneNumberKit.format(parsedNumber, toType: .e164))!
            actionComponents.scheme = "sms"
            
            
            var wrappedComponents = URLComponents()
            wrappedComponents.scheme = "speedboard"
            wrappedComponents.path = "/open"
            wrappedComponents.queryItems = [
                URLQueryItem(name: "url", value: "\(actionComponents.url!.absoluteString)")
            ]
            
            return wrappedComponents.url
        case .call:
            guard let phoneNumber = phoneNumber else { return nil }
            let parsedNumber = try! phoneNumberKit.parse(phoneNumber, ignoreType: true)
            var actionComponents = URLComponents(string: phoneNumberKit.format(parsedNumber, toType: .e164))!
            actionComponents.scheme = "tel"
            
            var wrappedComponents = URLComponents()
            wrappedComponents.scheme = "speedboard"
            wrappedComponents.path = "/open"
            wrappedComponents.queryItems = [
                URLQueryItem(name: "url", value: "\(actionComponents.url!.absoluteString)")
            ]
            
            return wrappedComponents.url
        case .facetime:
            guard let phoneNumber = phoneNumber else { return nil }
            let parsedNumber = try! phoneNumberKit.parse(phoneNumber, ignoreType: true)
            var actionComponents = URLComponents(string: phoneNumberKit.format(parsedNumber, toType: .e164))!
            actionComponents.scheme = "facetime"
            
            
            var wrappedComponents = URLComponents()
            wrappedComponents.scheme = "speedboard"
            wrappedComponents.path = "/open"
            wrappedComponents.queryItems = [
                URLQueryItem(name: "url", value: "\(actionComponents.url!.absoluteString)")
            ]
            
            return wrappedComponents.url
        case .empty:
            var components = URLComponents()
            components.scheme = "speedboard"
            components.host = "new"
            return components.url!
        }
        
    }
}

extension Action: Hashable {} 

extension Action: Identifiable {
    public var id: String { "\(self.position) - \(self.phoneNumber ?? "")" }
}
