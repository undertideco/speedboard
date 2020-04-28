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

struct ConfigurationView: View {
    @Binding var isPresented: Bool
    var indexPath: IndexPath
    
    @State private var user = ""
    @State private var isShowingContactSelector = false
    @State private var isShowingNumberSelector = false
    @State private var selectedContact: CNContact? = nil
    
    @State private var selectedActionType = ActionType.call
    @State private var selectedNumberIndex = 0

    var body: some View {
        NavigationView {
            Form {
                if selectedContact != nil {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        if selectedContact!.imageData != nil {
                            ShortcutImageView(type: self.selectedActionType, image: UIImage(data: selectedContact!.imageData!)!)
                        } else {
                            ShortcutImageView(type: self.selectedActionType, image: generateAvatarWithUsername(selectedContact!.givenName))
                        }
                        Spacer()
                    }

                    Picker(selection: $selectedActionType, label: Text("Action Type")) {
                        ForEach(ActionType.allCases, id: \.self) {
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
                        self.isShowingContactSelector = true
                        }) { Text("Select a Contact") }
                }
                
            }
            .navigationBarTitle(Text("Configure Action"))
            .navigationBarItems(trailing:
                Button("Save") {
                    print("Action Saved!")
                    self.saveAction()
                }.disabled(selectedContact == nil)
            )
        }.sheet(isPresented: $isShowingContactSelector) {
            EmbeddedContactPicker(didSelectContact: { contact in
                self.selectedContact = contact
                self.isShowingContactSelector = false
            }) {
                self.isShowingContactSelector = false
            }
        }
    }
    
    func generateAvatarWithUsername(_ name: String) -> UIImage {
        return  LetterAvatarMaker()
                    .setCircle(true)
                    .setUsername(name)
                    .build()!
    }
    
    func saveAction() {
        let imageData = generateAvatarWithUsername(selectedContact!.givenName).pngData()!
        let numbers = selectedContact!.phoneNumbers.compactMap { phoneNumber -> String? in
            return phoneNumber.value.stringValue
        }
        
        let action = Action(type: selectedActionType, position: indexPath, phoneNumber: numbers[self.selectedNumberIndex], image: imageData)
        ActionStore.shared.save(action)
        isPresented = false
    }
}
