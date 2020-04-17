//
//  ConfigurationCardView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

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
