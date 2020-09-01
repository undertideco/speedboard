//
//  LaunchCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct LaunchCell: View, Launchable {
    @Binding var deletable: Bool
    var action: Action
    
    var handlePressed: ((Action?) -> Void)?
    var onDelete: ((Action) -> Void)?
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            GeometryReader { geo in
                ZStack {
                    Circle().inset(by: 15).foregroundColor(Color.white)
                    // FIXME: not an ideal implementation for images
                    ShortcutImageView(type: action.type, image: UIImage(data: action.image ?? UIImage.imageWithColor(color: .clear).jpegData(compressionQuality: 70)!)!) {
                       self.handlePressed?(self.action)
                    }.frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75, alignment: .center)
                }
                .background(Color.lightBlue)
                .cornerRadius(20)
                .onTapGesture {
                    self.handlePressed?(self.action)
                }
            }

        
            if deletable {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
                    .offset(x: -5, y: -5)
                    .onTapGesture {
                        self.onDelete?(self.action)
                    }
            }
        }
    }
}
