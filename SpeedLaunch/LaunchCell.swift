//
//  LaunchCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 16/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct LaunchCell: View {
    var section: Int
    var row: Int
    var action: Action?
    
    var handleCellPressed: ((IndexPath) -> Void)?
    
    var body: some View {
        ZStack {
            if action != nil {
                Circle().inset(by: 15).foregroundColor(Color.white)
                ShortcutImageView(type: action!.type, image: UIImage(data: action!.image)!) {
                    self.handleCellPressed?(IndexPath(row: self.row, section: self.section))
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
            self.handleCellPressed?(IndexPath(row: self.row, section: self.section))
        }
    }
}
