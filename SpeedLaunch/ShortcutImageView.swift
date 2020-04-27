//
//  ShortcutImageView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 27/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import ContactsUI

struct ShortcutImageView: View {
    var type: ActionType
    var image: UIImage
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 75, height: 75)
                .mask(Circle())
            
            if type == .call {
                Image("call_glyph")
                    .foregroundColor(.green)
            } else if type == .message {
                Image("message_glyph")
                    .foregroundColor(.orange)
            } else {
                Image("gallery_glyph")
            }
        }
    }
}
