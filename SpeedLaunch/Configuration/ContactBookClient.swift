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
import Dependencies

enum ContactsError: Error {
    case permissionsError
    case imageUpdate
}

struct ContactBookClient {
    var requestContactBookPermission: () -> Effect<Bool>
    var saveNewContactImage: (Data, CNContact) -> Effect<Bool>
}

extension ContactBookClient {
    static var live = ContactBookClient(
        requestContactBookPermission: {
            .run { send in
                if CNContactStore.authorizationStatus(for: .contacts) != .notDetermined {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                    await send(false)
                } else {
                    let granted = await withCheckedContinuation { continuation in
                        CNContactStore().requestAccess(for: .contacts) { (granted, error) in
                            if let error = error {
                                continuation.resume(returning: false)
                            } else {
                                continuation.resume(returning: granted)
                            }
                        }
                    }
                    await send(granted)
                }
            }
        },
        saveNewContactImage: { imageData, contact in
            .run { send in
                guard let mutableContact = contact.mutableCopy() as? CNMutableContact else { 
                    await send(false)
                    return
                }
                
                mutableContact.imageData = imageData
                
                let saveRequest = CNSaveRequest()
                saveRequest.update(mutableContact)
                do {
                    try CNContactStore().execute(saveRequest)
                    await send(true)
                } catch {
                    await send(false)
                }
            }
        }
    )
}

// MARK: - Dependency Key
private enum ContactBookClientKey: DependencyKey {
    static let liveValue = ContactBookClient.live
    static let testValue = ContactBookClient.live // Use live for testing since it has proper async handling
    static let previewValue = ContactBookClient.live
}

extension DependencyValues {
    var contactBookClient: ContactBookClient {
        get { self[ContactBookClientKey.self] }
        set { self[ContactBookClientKey.self] = newValue }
    }
}