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

struct ConfigurationCardView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center) {
                Image("")
                    .frame(width: 18, height: 10, alignment: .trailing)
                Spacer()
                Text("Choose An Action")
                    .font(.system(.headline))
                Spacer()
                Image("down_chevron_glyph")
                    .frame(width: 18, height: 10, alignment: .trailing)
            }
            .frame(minHeight: 50)
            .padding([.horizontal], 16)
            HStack(alignment: .center, spacing: 52) {
                ActionView(type: .gallery)
                    .frame(maxWidth: 70, maxHeight: 70)
                ActionView(type: .message)
                    .frame(maxWidth: 70, maxHeight: 70)
                ActionView(type: .call)
                    .frame(maxWidth: 70, maxHeight: 70)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
        }
        .background(Color(red: 0.75, green: 0.89, blue: 0.95))
        .cornerRadius(20)
        .edgesIgnoringSafeArea(.all)
    }
}

struct LaunchCell: View {
    var handleCellPressed: (() -> Void)?
    
    var body: some View {
        ZStack {
            Circle().inset(by: 15).foregroundColor(Color.white)
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.90, green: 0.75, blue: 0.05))
        }
        .background(Color(red: 0.90, green: 0.94, blue: 0.94))
        .cornerRadius(20)
        .onTapGesture {
            self.handleCellPressed?()
        }
    }
}

struct ActionView: View {
    var type: ActionType
    
    var body: some View {
        ZStack {
            Color.clear
            if type == .call {
                Image("call_glyph")
            } else if type == .message {
                Image("message_glyph")
            } else {
                Image("gallery_glyph")
            }
        }
        .background(Color(red: 0.75, green: 0.89, blue: 0.95))
        .clipShape(Circle())
    }
}

enum ActionType {
    case gallery, message, call
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isShowingConfiguratorPopupCard: true)
    }
}
