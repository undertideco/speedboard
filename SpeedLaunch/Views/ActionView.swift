//
//  ActionView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

extension Color {
    static var actionViewGray = Color(red: 0.94, green: 0.94, blue: 0.94, opacity: 1)
}

struct ActionView: View {
    var type: ActionType
    
    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 5) {
                if type == .call {
                    Image(systemName: "phone.fill")
                    Text(Strings.call.rawValue)
                } else if type == .message {
                    Image(systemName: "message.fill")
                    Text(Strings.message.rawValue)
                } else {
                    Image(systemName: "video.fill")
                    Text(Strings.facetime.rawValue)
                }
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        }
        .background(Color.actionViewGray)
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

extension ActionView {
    enum Strings: LocalizedStringKey {
        case call = "Action_Call"
        case message = "Action_Message"
        case facetime = "Action_FaceTime"
    }
}


struct ActionView_Preview: PreviewProvider {
    static var previews: some View {
        HStack {
            ActionView(type: .call)
                .frame(width: 115, height: 72, alignment: .center)
            ActionView(type: .message)
                .frame(width: 115, height: 72, alignment: .center)
            ActionView(type: .facetime)
                .frame(width: 115, height: 72, alignment: .center)
        }

    }
}
