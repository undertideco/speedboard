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
    var handleTap: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .mask(Circle())
                .onTapGesture {
                    self.handleTap?()
                }
            
                        
            if type == .call {
                Image(systemName: "phone.fill")
                    .actionBadged()
            } else if type == .message {
                Image(systemName: "message.fill")
                    .actionBadged()
            } else if type == .facetime {
                Image(systemName: "video.fill")
                    .actionBadged()
            }
        }
    }
}

struct ActionBadge: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12))
            .foregroundColor(.white)
            .frame(width: 24, height: 24, alignment: .center)
            .background(Color.green)
            .cornerRadius(5.0)
    }
}

extension Image {
    func actionBadged() -> some View {
        self.modifier(ActionBadge())
    }
}

struct ShortcutImageView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            ShortcutImageView(type: .call, image: UIImage.imageWithColor(color: .blue))
                .frame(width: 100, height: 100, alignment: .center)
            ShortcutImageView(type: .message, image: UIImage.imageWithColor(color: .blue))
                .frame(width: 100, height: 100, alignment: .center)
            ShortcutImageView(type: .facetime, image: UIImage.imageWithColor(color: .blue))
                .frame(width: 100, height: 100, alignment: .center)
        }

    }
}
