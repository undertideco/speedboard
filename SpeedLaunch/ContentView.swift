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

struct ContentView: View {
    let store: Store<AppState, AppAction>
    
    @State var isShowingConfiguratorPopupCard = false
    @State var isShowingConfigurationScreen = false
    @State var isEditing: Bool = false
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack(alignment: .bottom) {
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        Button(self.isEditing ? "Done" : "Edit") {
                            self.isEditing = !self.isEditing
                        }
                        Image("applogo")
                            .frame(width: CGFloat(40), height: CGFloat(40))
                    }
                    Spacer()

                    QGrid(viewStore.actionsToDisplay ,columns: 3) { action in
                        Group {
                            if action.type == .empty {
                                EmptyLaunchCell(handlePressed: handleNewCellPressed)
                                    .frame(width: 100, height: 100, alignment: .center)
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
                            }
                        }
                    }

                    Spacer()
                    
                    if isShowingConfiguratorPopupCard {
                        ConfigurationCardView {
                            self.isShowingConfiguratorPopupCard = false
                        } handleCardActionSelected: { _ in
                            self.isShowingConfiguratorPopupCard = false
                            self.isShowingConfigurationScreen = true
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                    }
                }
                .contentShape(Rectangle())
            }
            .sheet(isPresented: $isShowingConfigurationScreen) {
                ConfigurationView(store: store,
                                  isPresented: self.$isShowingConfigurationScreen,
                                  index: viewStore.actionsToDisplay.count - 1)
            }
        }
    }
    
    func handleNewCellPressed() {
        guard self.isShowingConfiguratorPopupCard == false else { return }

        self.isShowingConfiguratorPopupCard = !isShowingConfiguratorPopupCard
    }
    
    func handleCellPressed(_ action: Action?) {
        guard self.isShowingConfiguratorPopupCard == false else { return }

        if let action = action,
            let urlString = action.generateURLLaunchSchemeString() {
            UIApplication.shared.open(urlString, options: [:])
        } else {
            self.isShowingConfiguratorPopupCard = !isShowingConfiguratorPopupCard
        }
    }
}

struct TestView: View {
    var body: some View {
        Circle()
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
