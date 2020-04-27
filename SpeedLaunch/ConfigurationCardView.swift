//
//  ConfigurationCardView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct ConfigurationCardView: View {    
    var handleCardDismiss: (() -> Void)?
    var handleCardActionSelected: ((ActionType) -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center) {
                Image("")
                    .frame(width: 18, height: 10, alignment: .trailing)
                Spacer()
                Text("Choose An Action")
                    .font(.system(.headline))
                Spacer()
                Button(action: {
                    self.handleCardDismiss?()
                }) {
                    Image("down_chevron_glyph")
                        .frame(width: 18, height: 10, alignment: .trailing)
                        .foregroundColor(.black)
                }.padding([.vertical], 8)
            }
            .frame(minHeight: 50)
            .padding([.horizontal], 16)
            HStack(alignment: .center, spacing: 52) {
                ActionView(type: .message)
                    .frame(maxWidth: 70, maxHeight: 70)
                    .onTapGesture {
                        self.handleCardActionSelected?(.message)
                    }
                ActionView(type: .call)
                    .frame(maxWidth: 70, maxHeight: 70)
                    .onTapGesture {
                        self.handleCardActionSelected?(.call)
                    }
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
