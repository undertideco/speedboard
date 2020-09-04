//
//  ConfigurationView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 20/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import LetterAvatarKit
import Contacts
import Combine
import ComposableArchitecture

enum ActiveConfigurationSheet {
    case contacts, photo
}

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

struct ConfigurationView: View {
    var store: Store<AppState, AppAction>
    let selectedContact: CNContact
    var selectedContactImage: UIImage {
        if let imageData = selectedContact.imageData {
            return  UIImage(data: imageData) ?? UIImage.generateWithName("\(selectedContact.givenName)")
        } else {
            return UIImage.generateWithName("\(selectedContact.givenName)")
        }
    }
    
    var index: Int
    var onDismiss: (() -> Void)?
        
    
    @State private var activeSheet: ActiveConfigurationSheet = .contacts

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    VStack(alignment: .center) {
                        ShortcutImageView(type: .empty, image: selectedContactImage)
                            .frame(width: 100, height: 100)
                        
                        Text(selectedContact.givenName)
                            .font(.system(size: 31))
                    }

                    
                    ForEach(ActionType.allCases.dropLast(), id: \.self) { actionType in
                        Section {
                            ForEach(selectedContact.contactInformationArr, id: \.self) { contact in
                                Button(action: {
                                    let imageData = selectedContactImage.pngData()!
                                    
                                    viewStore.send(.addAction(actionType, index, contact.value, imageData))
                                    self.onDismiss?()
                                }) {
                                    ConfigurationDataCell(actionType: actionType, label: contact.label, value: contact.value)
                                        .frame(height: 72)
                                }
                            }
                        }
                    }
                    
                }
                .navigationBarTitle(Text("Pick Action"))
            }
        }
    }
}
