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
    @NSManaged var isLargeWidgetDisplayable: Bool
    @NSManaged var isMediumWidgetDisplayable: Bool
    @NSManaged var contactBookIdentifier: String?
    
    var action : Action {
       get {
            return Action(
                id: id,
                type: ActionType(rawValue: actionType)!,
                contactValue: contactValue,
                imageData: image,
                createdTime: createdTime,
                actionName: name,
                isLargeWidgetDisplayable: isLargeWidgetDisplayable,
                isMediumWidgetDisplayable: isMediumWidgetDisplayable,
                contactBookIdentifier: contactBookIdentifier
            )
        }
        set {
            self.id = newValue.id
            self.name = newValue.actionName ?? ""
            self.image = newValue.imageData
            self.contactValue = newValue.contactValue ?? ""
            self.actionType = newValue.type.rawValue
            self.createdTime = newValue.createdTime
            self.contactBookIdentifier = newValue.contactBookIdentifier ?? nil
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
    var isLargeWidgetDisplayable: Bool = false
    var isMediumWidgetDisplayable: Bool = false
    var contactBookIdentifier: String? = nil
    
    init(id: UUID, type: ActionType, contactValue: String?, imageData: Data?, createdTime: Date, actionName: String? = nil, isLargeWidgetDisplayable: Bool = false, isMediumWidgetDisplayable: Bool = false, contactBookIdentifier: String? = nil) {
        self.id = id
        self.type = type
        self.contactValue = contactValue
        self.imageData = imageData
        self.createdTime = createdTime
        self.actionName = actionName
        self.isLargeWidgetDisplayable = isLargeWidgetDisplayable
        self.isMediumWidgetDisplayable = isMediumWidgetDisplayable
        self.contactBookIdentifier = contactBookIdentifier
    }
    
    init(action: Action, newImageData: Data) {
        self.init(id: action.id, type: action.type, contactValue: action.contactValue, imageData: newImageData, createdTime: action.createdTime, actionName: action.actionName, isLargeWidgetDisplayable: action.isLargeWidgetDisplayable, isMediumWidgetDisplayable: action.isMediumWidgetDisplayable, contactBookIdentifier: action.contactBookIdentifier)
    }
    
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
        guard let value = contactValue else {
            return URL(string: "speedboard://addWidget")
        }
        
        if value.isEmail {
            return type.urlLaunchScheme(value)
        } else {
            do {
                let phoneNumberUtility = PhoneNumberUtility()
                let phoneNumber = try phoneNumberUtility.parse(value)
                
                let e164Number = phoneNumberUtility.format(phoneNumber, toType: .e164)
                return type.urlLaunchScheme(e164Number)
            } catch {
                return type.urlLaunchScheme(value)
            }
        }
    }
}

extension Action: Hashable {} 
