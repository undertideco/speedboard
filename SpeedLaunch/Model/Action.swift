//
//  Action.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import CoreData
import PhoneNumberKit

class SavedAction: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var actionType: String
    @NSManaged var contactValue: String
    @NSManaged var createdTime: Date
    @NSManaged var image: Data?
    @NSManaged var name: String
    
    var action : Action {
       get {
            return Action(
                id: id,
                type: ActionType(rawValue: actionType)!,
                contactValue: contactValue,
                imageData: image,
                createdTime: createdTime,
                actionName: name
            )
        }
        set {
            self.id = newValue.id
            self.name = newValue.actionName ?? ""
            self.image = newValue.imageData
            self.contactValue = newValue.contactValue ?? ""
            self.actionType = newValue.type.rawValue
            self.createdTime = newValue.createdTime
        }
    }
}

struct Action: Codable, Equatable, Identifiable {
    let id: UUID
    let type: ActionType
    let contactValue: String?
    let imageData: Data?
    let createdTime: Date
    var actionName: String? = nil
    
    var accessibilityLabel: String {
        switch type {
        case .message:
            return "Text \(actionName!) at \(contactValue ?? "")"
        case .call:
            return "Call \(actionName!) at \(contactValue ?? "")"
        case .facetime:
            return "FaceTime \(actionName!) at \(contactValue ?? "")"
        case .empty:
            return ""
        }
    }
    
    func generateURLLaunchSchemeString() -> URL? {
        guard let value = contactValue else { return nil }
        
        if value.isEmail {
            return type.urlLaunchScheme(value)
        } else {
            let phoneNumberKit = PhoneNumberKit()
            
            let parsedNumber = try! phoneNumberKit.parse(value,
                                                         ignoreType: true)
            return type.urlLaunchScheme(phoneNumberKit.format(parsedNumber, toType: .e164))
        }
    }
}

extension Action: Hashable {} 
