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
    
    @State private var selectedContact: CNContact? = nil
    @State private var showSettings: Bool = false
    
    @State var cardPosition: CardPosition = .middle
    
    var actionsPerRow: Int {
        if UIDevice.current.userInterfaceIdiom == .phone{
            return 3
        } else {
            return 5
        }
    }
    
    var actionCellDimension: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone{
            return 100
        } else {
            return 150
        }
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    ContactPicker(
                        showPicker: viewStore.binding(
                            get: \.isContactPickerOpen,
                            send: AppAction.setContactPickerPresentation
                        )
                    ) { contact in
                        viewStore.send(.presentContactsConfigurator(contact))
                    } onCancel: {
                        viewStore.send(.setContactPickerPresentation(false))
                    }
                    QGrid(viewStore.actionsToDisplay, columns: actionsPerRow) { action in
                        Group {
                            if action.type == .empty {
                                EmptyLaunchCell(localizedString: Strings.emptyCellTitle.rawValue) {
                                    viewStore.send(.setContactPickerPresentation(!viewStore.isContactPickerOpen))
                                }
                                .frame(width: actionCellDimension, height: actionCellDimension, alignment: .center)
                                .padding(5)
                            } else {
                                LaunchCell(deletable: viewStore.binding(
                                            get: \.isEditing,
                                            send: AppAction.setEditing
                                           ),
                                           action: action,
                                           handlePressed: { action in
                                            guard !viewStore.isEditing else { return }
                                                if let action = action,
                                                    let urlString = action.generateURLLaunchSchemeString() {
                                                    UIApplication.shared.open(urlString, options: [:])
                                                }
                                           },
                                           onDelete: { action in
                                                viewStore.send(
                                                    .deleteAction(action)
                                                )
                                           })
                                    .frame(width: actionCellDimension, height: actionCellDimension, alignment: .center)
                                    .padding(5)
                            }
                        }
                    }.accessibility(label: Text(Strings.actionsGrid.rawValue))
                    
                    if #available(iOS 14.0, *) {
                        if viewStore.isEditing {
                            SlideOverCard(position: cardPosition) {
                                WidgetConfigurationView(
                                    store: self.store.scope(
                                        state: \.actions,
                                        action: AppAction.widgetConfiguration
                                    ),
                                    actions: viewStore.actionsToDisplay
                                )
                            }
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut)
                            .accessibilityAddTraits([.isHeader])
                            .accessibility(label: Text(Strings.configurationCardLabel.rawValue))
                            .accessibility(hint: Text(Strings.configurationCardHint.rawValue))
                        }
                    }
                }
                .navigationBarTitle(
                    Text(Strings.title.rawValue),
                    displayMode: .inline
                )
                .navigationBarColor(
                    backgroundColor: UIColor(named: "primary")!,
                    tintColor: .white
                )
                .navigationBarItems(
                    leading: HStack {
                        Button(action: {
                            viewStore.send(.presentSettingsScreen)
                        }, label: {
                            Image(systemName: "gear")
                                .font(.title)
                                .foregroundColor(.white)
                                .scaleEffect(0.9)
                        })
                    },
                    trailing: Button(action: {
                        viewStore.send(.setEditing(!viewStore.isEditing))
                    }, label: {
                        if viewStore.isEditing {
                            Image(systemName: "checkmark")
                                .font(.title)
                                .foregroundColor(.white)
                                .scaleEffect(0.9)
                                .accessibility(label: Text(Strings.saveButton.rawValue))
                        } else {
                            Image(systemName: "pencil")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .scaleEffect(0.9)
                                .accessibility(label: Text(Strings.editButton.rawValue))
                                .accessibility(hint: Text(Strings.editButtonHint.rawValue))
                        }
                    }).foregroundColor(
                        viewStore.isEditing ? .green : .blue
                        
                    )
                )
            }
            .sheet(item: viewStore.binding( get: \.presenting, send: AppAction.setPresentingSheet)) { item in
                switch item {
                case .contacts:
                    ConfigurationView(
                        store: self.store.scope(
                            state: { $0.configurationState },
                            action: AppAction.configurationView
                        ),
                        index: viewStore.actionsToDisplay.count - 1
                    ) {
                        self.selectedContact = nil
                    }
                case .settings:
                    SettingsView()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                viewStore.send(.loadActions)
            }
        }
    }
}

extension HomeView {
    enum Strings: LocalizedStringKey {
        case title = "Home_Title"
        case emptyCellTitle = "LaunchCell_EmptyTitle"
        
        case actionsGrid = "Accessibility_HomeView_Grid_Label"
        case editButton = "Accessibility_HomeView_EditButton_Label"
        case saveButton = "Accessibility_HomeView_SaveButton_Label"
        case editButtonHint = "Accessibility_HomeView_EditButton_Hint"
        
        case configurationCardLabel = "Accessibility_HomeView_ConfigurationCard_Label"
        case configurationCardHint = "Accessibility_HomeView_ConfigurationCard_Hint"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store:
                        Store(initialState: AppState(),
                              reducer: appReducer,
                              environment: AppEnvironment(storageClient: .mock))
        )
    }
}
