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
    var style: LaunchCell.CellStyle = .large
    
    var handlePressed: ((Action?) -> Void)?
    var onDelete: ((Action) -> Void)?
    
    enum CellStyle {
        case small, large
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            GeometryReader { geo in
                VStack {
                    ZStack {
                        Circle().inset(by: 15).foregroundColor(Color.white)
                        // FIXME: not an ideal implementation for images
                        if action.imageUrl != nil {
                            ShortcutImageView(type: action.type, image: UIImage(contentsOfFile: action.imageUrl!.path)!) {
                                self.handlePressed?(self.action)
                            }.frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75, alignment: .center)
                        } else {
                            ShortcutImageView(type: action.type, image: UIImage.imageWithColor(color: .clear)) {
                                self.handlePressed?(self.action)
                            }.frame(width: geo.size.width * 0.75, height: geo.size.height * 0.75, alignment: .center)
                        }
                    }
                    
                    if style == .large {
                        Text("Hello World")
                            .font(.system(size: 13))
                    }
                }
                .cellTappable(style: style)
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

extension View {
    func cellTappable(style: LaunchCell.CellStyle) -> some View {
        self.modifier(LaunchCellDecorator(style: style))
    }
}

struct LaunchCellDecorator: ViewModifier {
    var style: LaunchCell.CellStyle
    
    func body(content: Content) -> some View {
        Group {
            if style == .large {
                content
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(Color("launchcell_bg"))
                    .cornerRadius(20)
            } else {
                content
                    .background(Color("launchcell_bg"))
                    .cornerRadius(20)
            }
        }
    }
}

