//
//  ContentView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import QGrid
import ComposableArchitecture
import Contacts
import LetterAvatarKit

enum ActiveConfigSheet {
    case contact, action
}

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    @State var isEditing: Bool = false
    
    @State private var selectedContactImage: UIImage?
    @State private var selectedContact: CNContact? = nil
    
    @State private var showSheet: Bool = false
    @State private var activeSheet: ActiveConfigSheet = .contact
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                QGrid(viewStore.actionsToDisplay ,columns: 3) { action in
                    Group {
                        if action.type == .empty {
                            EmptyLaunchCell(handlePressed: handleNewCellPressed)
                                .frame(width: 100, height: 100, alignment: .center)
                                .padding(5)
                        } else {
                            LaunchCell(deletable: self.$isEditing,
                                       action: action,
                                       handlePressed: handleCellPressed,
                                       onDelete: { action in
                                            viewStore.send(
                                                .deleteAction(viewStore.actionsToDisplay.firstIndex(of: action)!)
                                            )
                                       })
                                .frame(width: 100, height: 100, alignment: .center)
                                .padding(5)
                        }
                    }
                }
                .navigationBarTitle(Text("Speedboard"), displayMode: .inline)
                .navigationBarItems(trailing:
                        Button(action: {
                            self.isEditing = !self.isEditing
                        }) {
                            if self.isEditing {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                            } else {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.largeTitle)
                            }
                        }.foregroundColor(self.isEditing ? .green : .blue)
                )
            }.sheet(isPresented: $showSheet) {
                switch activeSheet {
                case .contact:
                    EmbeddedContactPicker(didSelectContact: { contact in
                        self.loadContactAndImages(contact)
                        self.activeSheet = .action
                    }) {
                        self.activeSheet = .action
                    }
                case .action:
                    if selectedContact !=  nil {
                        ConfigurationView(store: store,
                                          selectedContact: selectedContact!,
                                          index: viewStore.actionsToDisplay.count - 1) {
                            self.showSheet = false
                            self.activeSheet = .contact
                        }
                    }
                }
                
            }
        }
    }
    
    func loadContactAndImages(_ contact: CNContact) {
        self.selectedContact = contact
        if let imageData = contact.imageData {
            selectedContactImage = UIImage(data: imageData)
        } else {
            selectedContactImage = UIImage.generateWithName("\(contact.givenName)")
        }
    }
    
    func handleNewCellPressed() {
        self.activeSheet = .contact
        self.showSheet = true
    }
    
    func handleCellPressed(_ action: Action?) {
        if let action = action,
            let urlString = action.generateURLLaunchSchemeString() {
            UIApplication.shared.open(urlString, options: [:])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store:
                        Store(initialState: AppState(),
                              reducer: appReducer,
                              environment: AppEnvironment())
        )
    }
}
