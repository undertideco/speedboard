//
//  ContactBookClient.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 11/6/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Contacts

struct ContactBookClient {
    var requestContactBookPermission: () -> Effect<Bool, Error>
}

extension ContactBookClient {
    static var live = ContactBookClient(
        requestContactBookPermission: {
            .future { callback in
                CNContactStore().requestAccess(for: .contacts) { (granted, error) in
                    
                    if let error = error {
                        return callback(.failure(error))
                    }
                    
                    return callback(.success(granted))
                }
            }
        }
    )
}
