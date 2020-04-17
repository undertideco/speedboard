//
//  ActionView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

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
