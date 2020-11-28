//
//  ContactBookClient.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 11/6/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import UIKit
import ComposableArchitecture
import Contacts

enum ContactsError: Error {
    case permissionsError
    case imageUpdate
}

struct ContactBookClient {
    var requestContactBookPermission: () -> Effect<Bool, ContactsError>
    var saveNewContactImage: (Data, CNContact) -> Effect<Bool, ContactsError>
}

extension ContactBookClient {
    static var live = ContactBookClient(
        requestContactBookPermission: {
            .future { callback in
                if CNContactStore.authorizationStatus(for: .contacts) != .notDetermined {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                } else {
                    CNContactStore().requestAccess(for: .contacts) { (granted, error) in
                        
                        if let error = error {
                            return callback(.failure(.permissionsError))
                        }
                        
                        return callback(.success(granted))
                    }
                }
            }
        },
        saveNewContactImage: { imageData, contact in
            .future { callback in
                guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { return callback(.failure(.imageUpdate)) }
                
                mutableContact.imageData = imageData
                
                let saveRequest = CNSaveRequest()
                saveRequest.update(mutableContact)
                do {
                    try CNContactStore().execute(saveRequest)
                    return callback(.success(true))
                } catch {
                    return callback(.failure(.imageUpdate))
                }
            }
        }
    )
}
