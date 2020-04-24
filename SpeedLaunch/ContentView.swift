//
//  ContentView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var isShowingConfiguratorPopupCard = false
    @State var isShowingConfigurationScreen = false
    @State var selectedIndexPath: IndexPath? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Spacer()
                Image("applogo")
                    .frame(width: CGFloat(40), height: CGFloat(40))
                Spacer()
            }
            Spacer()
            VStack(alignment: .center, spacing: 16) {
                generate(row: 4, col: 3)
            }.animation(.easeInOut)
            
            Spacer()
            
            if isShowingConfiguratorPopupCard {
                ConfigurationCardView(handleCardDismiss: {
                    self.isShowingConfiguratorPopupCard = false
                }, handleCardActionSelected: { actionType in
                    self.isShowingConfiguratorPopupCard = false
                    self.isShowingConfigurationScreen = true
                })
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.selectedIndexPath = nil
            self.isShowingConfiguratorPopupCard = false
        }
        .sheet(isPresented: $isShowingConfigurationScreen) {
            ConfigurationView(isPresented: self.$isShowingConfigurationScreen, indexPath: self.selectedIndexPath!)
        }
    }
    
    func generate(row: Int, col: Int) -> some View {
        ForEach(0...row - 1, id: \.self) { r in
            HStack(alignment: .center, spacing: 16) {
                self.generateRow(with: col, at: r)
            }
        }
    }
     
    func generateRow(with count: Int, at row: Int) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ForEach(0...count - 1, id: \.self) { s in
                LaunchCell(section: s, row: row, action: self.action(at: IndexPath(row: row, section: s)),handleCellPressed: self.handleCellPressed)
                    .frame(width: 100, height: 100)
            }
        }
    }
    
    func action(at indexPath: IndexPath) -> Action? {
        return ActionStore.shared.item(at: indexPath)
    }
    
    func handleCellPressed(indexPath: IndexPath) {
        guard self.isShowingConfiguratorPopupCard == false else { return }
        
        if let action = ActionStore.shared.item(at: indexPath) {
            UIApplication.shared.open(action.generateURLLaunchSchemeString(), options: [:])
        } else {
            self.selectedIndexPath = indexPath
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
