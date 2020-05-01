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
    @State var selectedIndex: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Spacer()
                    Image("applogo")
                        .frame(width: CGFloat(40), height: CGFloat(40))
                    Spacer()
                }
                Spacer()
                
                CollectionView(data: ActionStore.shared.actions, layout: flowLayout) {
                    LaunchCell(action: $0) {
                        self.handleCellPressed($0)
                    }
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
            .frame(height: 40)
        }
    }
    
    func handleCellPressed(_ action: Action?) {
        guard self.isShowingConfiguratorPopupCard == false else { return }

        if let action = action {
            UIApplication.shared.open(action.generateURLLaunchSchemeString(), options: [:])
        } else {
            self.isShowingConfiguratorPopupCard = !isShowingConfiguratorPopupCard
        }
    }
    
    func flowLayout<Elements>(for elements: Elements, containerSize: CGSize, sizes: [Elements.Element.ID: CGSize]) -> [Elements.Element.ID: CGSize] where Elements: RandomAccessCollection, Elements.Element: Identifiable {
        var state = FlowLayout(containerSize: containerSize)
        var result: [Elements.Element.ID: CGSize] = [:]
        for element in elements {
            let rect = state.add(element: sizes[element.id] ?? .zero)
            result[element.id] = CGSize(width: rect.origin.x, height: rect.origin.y)
        }
        return result
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
