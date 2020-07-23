//
//  ContentView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import QGrid

struct ContentView: View {
    @State var isShowingConfiguratorPopupCard = false
    @State var isShowingConfigurationScreen = false
    @State var selectedIndex: Int = 0
    @State var isEditing: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Button(isEditing ? "Done" : "Edit") {
                        self.isEditing = !self.isEditing
                    }
                    Image("applogo")
                        .frame(width: CGFloat(40), height: CGFloat(40))
                }
                Spacer()
                
                QGrid(ActionStore.shared.actionsToDisplay, columns: 3) { action in
                    LaunchCell(deletable: self.$isEditing, action: action, handleCellPressed: self.handleCellPressed(_:))
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.isShowingConfiguratorPopupCard = false
            }
            
            if isShowingConfiguratorPopupCard {
                ConfigurationCardView(handleCardDismiss: {
                    self.isShowingConfiguratorPopupCard = false
                }) { _ in
                    self.isShowingConfiguratorPopupCard = false
                    self.isShowingConfigurationScreen = true
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut)
            }
        }
        .sheet(isPresented: $isShowingConfigurationScreen) {
            ConfigurationView(isPresented: self.$isShowingConfigurationScreen, index: self.selectedIndex)
        }
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
        ContentView(isShowingConfiguratorPopupCard: true)
    }
}
