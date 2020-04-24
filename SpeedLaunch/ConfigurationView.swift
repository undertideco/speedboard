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
    @State private var selectedContact: CNContact? = nil
    
    @State private var selectedActionType = 0
    
    var body: some View {
        NavigationView {
            Form {
                if selectedContact != nil {
                    Image(uiImage: generateAvatarWithUsername(selectedContact!.givenName))
                    Picker(selection: $selectedActionType, label: Text("Action Type")) {
                        ForEach(0 ..< ActionType.allCases.count) {
                            Text(ActionType.allCases[$0].rawValue.capitalized)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    Text("Contact Name: \(selectedContact!.givenName)")
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
        let action = Action(type: ActionType.allCases[selectedActionType], position: indexPath, image: imageData)
        
        ActionStore.shared.save(action)
        isPresented = false
    }
}
