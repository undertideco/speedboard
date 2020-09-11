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

struct HomeView: View {
    @Environment(\.navCoordinator) var navCoordinator

    let store: Store<AppState, AppAction>
    
    @State var isEditing: Bool = false
    
    @State private var selectedContact: CNContact? = nil
    @State private var showContactPicker: Bool = false
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    ContactPicker(showPicker: $showContactPicker) { contact in
                        self.selectedContact = contact
                    } onCancel: {
                        self.showContactPicker = false
                    }
                    QGrid(viewStore.actionsToDisplay ,columns: 3) { action in
                        Group {
                            if action.type == .empty {
                                EmptyLaunchCell(displayString: "New Action", handlePressed: handleNewCellPressed)
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
                }
                .onReceive(navCoordinator.urlToOpen, perform: {
                    self.handleOpenURL($0)
                })
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
            }.sheet(item: $selectedContact) { contact in
                ConfigurationView(store: store, selectedContact: contact, index: viewStore.actionsToDisplay.count - 1) {
                    self.selectedContact = nil
                }
            }
        }
    }

    func handleNewCellPressed() {
        self.showContactPicker = true
    }
    
    func handleCellPressed(_ action: Action?) {
        guard !isEditing else { return }
        if let action = action,
            let urlString = action.generateURLLaunchSchemeString() {
            UIApplication.shared.open(urlString, options: [:])
        }
    }
    
    func handleOpenURL(_ url: URL) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                let actionPath = components.host,
                let actionType = URLSchemeActions(rawValue: actionPath) else {
                    print("No action present")
                    return
            }
        
        switch actionType {
        case .new:
            self.showContactPicker = true
        case .open:
            guard let params = components.queryItems else {
                print("No URL To Open")
                return
            }
            if let urlToLaunch = params.first(where: { $0.name == "url" })?.value {
                print("urlToLaunch = \(urlToLaunch)")
                UIApplication.shared.open(URL(string: urlToLaunch)!, options: [:])
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store:
                        Store(initialState: AppState(),
                              reducer: appReducer,
                              environment: AppEnvironment())
        )
    }
}
