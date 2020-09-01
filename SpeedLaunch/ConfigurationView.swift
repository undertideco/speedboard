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
    
    @State private var selectedNumberIndex = 0
    @State private var activeSheet: ActiveConfigurationSheet = .contacts

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                Form {
                    if selectedContact != nil {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            ShortcutImageView(type: self.selectedActionType, image: selectedContactImage ?? generateAvatarWithUsername(selectedContact!.givenName)) {
                                self.isShowingSheet = true
                                self.activeSheet = .photo
                            }
                            .frame(width: 100, height: 100)
                            Spacer()
                        }

                        Picker(selection: $selectedActionType, label: Text("Action Type")) {
                            ForEach(ActionType.allCases.dropLast(), id: \.self) {
                                Text("\($0.rawValue)".capitalized)
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                        

                        Picker(selection: $selectedNumberIndex, label: Text("   ")) {
                            ForEach(selectedContact!.phoneNumbers, id: \.self) {
                                Text("\($0.value.stringValue)")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        
                    } else {
                        Button(action: {
                            self.isShowingSheet = true
                            self.activeSheet = .contacts
                            }) { Text("Select a Contact") }
                    }
                    
                }
                .navigationBarTitle(Text("Configure Action"))
                .navigationBarItems(trailing:
                    Button("Save") {
                        print("Action Saved!")
                        self.saveAction(in: viewStore)
                    }.disabled(selectedContact == nil)
                )
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
    
    func saveAction(in viewStore: ViewStore<AppState, AppAction>) {
        let imageData = selectedContactImage?.jpegData(compressionQuality: 30) ?? generateAvatarWithUsername(selectedContact!.givenName).pngData()!
        
        let numbers = selectedContact!.phoneNumbers.compactMap { phoneNumber -> String? in
            return phoneNumber.value.stringValue
        }
        
        viewStore.send(.addAction(selectedActionType, index, numbers[self.selectedNumberIndex], imageData))
        
        isPresented = false
    }
}
