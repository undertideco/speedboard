//
//  CellLaunchable.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 25/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

protocol Launchable: View {
    associatedtype CellDataType
    
    var style: LaunchableCellStyle { get set }
    var handlePressed: ((CellDataType) -> Void)? { get set }
}

enum LaunchableCellStyle {
    case small, large
}

struct LaunchCellDecorator: ViewModifier {
    var style: LaunchableCellStyle
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        Group {
            if style == .large {
                content
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(backgroundColor)
                    .cornerRadius(20)
            } else {
                content
                    .background(backgroundColor)
                    .cornerRadius(20)
            }
        }
    }
}

extension View {
    func cellTappable(style: LaunchableCellStyle, color: Color) -> some View {
        self.modifier(LaunchCellDecorator(style: style, backgroundColor: color))
    }
}

