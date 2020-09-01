//
//  ActionWidgetResizable.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 8/31/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

extension LaunchCell {
    func actionResizable(geo: GeometryProxy, rows: Int, cols: Int) -> some View {
        self.modifier(ActionWidgetResizable(geo: geo, rows: rows, cols: cols))
    }
}

struct ActionWidgetResizable: ViewModifier {
    let geo: GeometryProxy
    let rows: Int
    let cols: Int
    
    var edgeLength: CGFloat {
        min(geo.size.width / CGFloat(cols), geo.size.height / CGFloat(rows))
    }
    
    func body(content: Content) -> some View {
        content
            .frame(width: edgeLength, height: edgeLength, alignment: .center)
    }
}
