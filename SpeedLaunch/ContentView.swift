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
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                }
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                }
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                }
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                    LaunchCell(handleCellPressed: self.handleCellPressed).frame(width: 100, height: 100)
                }
            }.animation(.easeInOut)
            
            Spacer()
            
            if isShowingConfiguratorPopupCard {
                ConfigurationCardView()
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
            }
            
        }
    }
    
    func handleCellPressed() {
//        guard self.isShowingConfiguratorPopupCard == false else { return }
        self.isShowingConfiguratorPopupCard = !isShowingConfiguratorPopupCard
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isShowingConfiguratorPopupCard: true)
    }
}
