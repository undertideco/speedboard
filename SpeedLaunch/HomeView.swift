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
    let store: Store<AppState, AppAction>
    
    @State var isEditing: Bool = false
    @State private var selectedContact: CNContact? = nil
    
    @State var cardPosition: CardPosition = .middle
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    ContactPicker(
                        showPicker: viewStore.binding(
                            get: \.isContactPickerOpen,
                            send: AppAction.setPicker
                        )
                    ) { contact in
                        self.selectedContact = contact
                    } onCancel: {
                        viewStore.send(.setPicker(false))
                    }
                    QGrid(viewStore.actionsToDisplay ,columns: 3) { action in
                        Group {
                            if action.type == .empty {
                                EmptyLaunchCell(localizedString: Strings.emptyCellTitle.rawValue) {
                                    viewStore.send(.setPicker(!viewStore.isContactPickerOpen))

                                }
                                .frame(width: 100, height: 100, alignment: .center)
                                .padding(5)
                            } else {
                                LaunchCell(deletable: self.$isEditing,
                                           action: action,
                                           handlePressed: handleCellPressed,
                                           onDelete: { action in
                                                viewStore.send(
                                                    .deleteAction(action)
                                                )
                                           })
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .padding(5)
                            }
                        }
                    }
                    
                    if #available(iOS 14.0, *) {
                        if isEditing {
                            SlideOverCard(position: cardPosition) {
                                WidgetConfigurationView(
                                    store: self.store.scope(
                                        state: \.widgetConfigurationState,
                                        action: AppAction.widgetConfiguration
                                    ),
                                    actions: viewStore.actionsToDisplay
                                )
                            }
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut)
                        }
                    }
                }
                .navigationBarTitle(
                    Text(Strings.title.rawValue),
                    displayMode: .automatic
                )
                .navigationBarColor(
                    backgroundColor: UIColor(named: "primary")!,
                    tintColor: .white
                )
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            self.isEditing = !self.isEditing
                        }) {
                            if self.isEditing {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        }.foregroundColor(self.isEditing ? .green : .blue
                        )
                )
            }
            .sheet(item: $selectedContact) { contact in
                ConfigurationView(
                    store: store,
                    selectedContact: contact,
                    index: viewStore.actionsToDisplay.count - 1
                ) {
                    self.selectedContact = nil
                }
            }
        }
    }
    
    func handleCellPressed(_ action: Action?) {
        guard !isEditing else { return }
        if let action = action,
            let urlString = action.generateURLLaunchSchemeString() {
            UIApplication.shared.open(urlString, options: [:])
        }
    }
}

extension HomeView {
    enum Strings: LocalizedStringKey {
        case title = "App_Name"
        case emptyCellTitle = "LaunchCell_EmptyTitle"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store:
                        Store(initialState: AppState(),
                              reducer: testReducer,
                              environment: AppEnvironment())
        )
    }
}
