//
//  ContentView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image("applogo")
                    .frame(width: CGFloat(40), height: CGFloat(40))
                Spacer()
            }
            Spacer()
            VStack(alignment: .center, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                }
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                }
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                }
                HStack(alignment: .center, spacing: 16) {
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                    LaunchCell().frame(width: 100, height: 100)
                }
            }
            
            Spacer()
        }
    }
}

struct LaunchCell: View {
    var body: some View {
        ZStack {
            Circle().inset(by: 15).foregroundColor(Color.white)
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .regular, design: .default))
                .foregroundColor(Color(red: 0.90, green: 0.75, blue: 0.05))
        }
        .background(Color(red: 0.90, green: 0.94, blue: 0.94))
        .cornerRadius(20)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
