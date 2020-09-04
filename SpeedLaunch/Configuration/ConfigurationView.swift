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
    @Binding var isPresented: Bool
    @Binding var selectedActionType: ActionType
    var index: Int
    
    @State private var user = ""
    @State private var isShowingNumberSelector = false
    @State private var isShowingSheet = false
    
    @State private var selectedContactImage: UIImage?
    @State private var selectedContact: CNContact? = nil
    
    @State private var activeSheet: ActiveConfigurationSheet = .contacts

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    if selectedContact != nil {
                        VStack(alignment: .center) {
                            ShortcutImageView(type: self.selectedActionType, image: selectedContactImage ?? generateAvatarWithUsername(selectedContact!.givenName)) {
                                self.isShowingSheet = true
                                self.activeSheet = .photo
                            }
                            .frame(width: 100, height: 100)
                            
                            Text(selectedContact!.givenName)
                                .font(.system(size: 31))
                        }

                        
                        ForEach(ActionType.allCases.dropLast(), id: \.self) { actionType in
                            Section {
                                ForEach(selectedContact!.contactInformationArr, id: \.self) { contact in
                                    Button(action: {
                                        let imageData = selectedContactImage?.jpegData(compressionQuality: 30) ?? generateAvatarWithUsername(selectedContact!.givenName).pngData()!
                                        
                                        viewStore.send(.addAction(actionType, index, contact.value, imageData))
                                        
                                        isPresented = false
                                    }) {
                                        ConfigurationDataCell(actionType: actionType, label: contact.label, value: contact.value)
                                            .frame(height: 72)
                                    }
                                }
                            }
                        }
                        
                    } else {
                        Button(action: {
                            self.isShowingSheet = true
                            self.activeSheet = .contacts
                            }) { Text("Select a Contact") }
                    }
                    
                }
                .navigationBarTitle(Text("Pick Action"))
            }.sheet(isPresented: $isShowingSheet) {
                if self.activeSheet == .contacts {
                    EmbeddedContactPicker(didSelectContact: { contact in
                        self.loadContactAndImages(contact)
                        self.isShowingSheet = false
                    }) {
                        self.isShowingSheet = false
                    }
                } else if self.activeSheet == .photo {
                    ImagePicker(image: self.$selectedContactImage)
                }
            }
        }
    }
    
    func generateAvatarWithUsername(_ name: String) -> UIImage {
        return  LetterAvatarMaker()
                    .setCircle(true)
                    .setUsername(name)
                    .build()!
    }
    
    func loadContactAndImages(_ contact: CNContact) {
        self.selectedContact = contact
        if let imageData = contact.imageData {
            selectedContactImage = UIImage(data: imageData)
        } else {
            selectedContactImage = generateAvatarWithUsername("\(contact.givenName)")
        }
    }
}
