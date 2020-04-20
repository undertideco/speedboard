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
            self.isShowingConfiguratorPopupCard = false
        }
        .sheet(isPresented: $isShowingConfigurationScreen) {
            ConfigurationView()
        }
    }
    
    func generate(row: Int, col: Int) -> some View {
        ForEach(0...row - 1, id: \.self) { _ in
            HStack(alignment: .center, spacing: 16) {
                self.generateRow(with: col)
            }
        }
    }
     
    func generateRow(with count: Int) -> some View {
        HStack(alignment: .center, spacing: 16) {
            ForEach(0...count - 1, id: \.self) {_ in
                LaunchCell(handleCellPressed: self.handleCellPressed)
                    .frame(width: 100, height: 100)
            }
        }
    }
    
    func handleCellPressed() {
        guard self.isShowingConfiguratorPopupCard == false else { return }
        self.isShowingConfiguratorPopupCard = !isShowingConfiguratorPopupCard
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
