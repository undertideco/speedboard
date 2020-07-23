//
//  LaunchCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct LaunchCell: View {
    @Binding var deletable: Bool
    var action: Action
    
    var handleCellPressed: ((Action?) -> Void)?
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            ZStack {
                if action.type != .empty {
                    Circle().inset(by: 15).foregroundColor(Color.white)
                    // FIXME: not an ideal implementation for images
                    ShortcutImageView(type: action.type, image: UIImage(data: action.image ?? UIImage.imageWithColor(color: .clear).jpegData(compressionQuality: 70)!)!) {
                       self.handleCellPressed?(self.action)
                    }

                } else {
                    Circle().inset(by: 15).foregroundColor(Color.white)
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .regular, design: .default))
                        .foregroundColor(Color(red: 0.90, green: 0.75, blue: 0.05))
                }
            }
            .background(Color(red: 0.90, green: 0.94, blue: 0.94))
            .cornerRadius(20)
            .onTapGesture {
                self.handleCellPressed?(self.action)
            }
            .frame(width: 100, height: 100, alignment: .center)
        
            if deletable {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
                    .offset(x: -5, y: -5)
            }
        }
        
        
    }
}
