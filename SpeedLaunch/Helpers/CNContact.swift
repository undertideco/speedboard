//
//  CNContact.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import Foundation
import Contacts

struct ContactInfo: Hashable {
    let value: String
    let label: String
}

extension CNContact {
    var contactInformationArr: [ContactInfo] {
        return phoneNumbers.map{ ContactInfo(value: $0.value.stringValue, label: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0.label ?? "Phone")) } +
            emailAddresses.map{ ContactInfo(value: String($0.value), label: CNLabeledValue<NSString>.localizedString(forLabel: $0.label ?? "Email")) }
    }
}

extension CNContact: Identifiable {}
