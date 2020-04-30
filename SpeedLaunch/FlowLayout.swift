//
//  FlowLayout.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 30/4/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct FlowLayout {
    let spacing: UIOffset
    let containerSize: CGSize
    
    init(containerSize: CGSize, spacing: UIOffset = UIOffset(horizontal: 10, vertical: 10)) {
        self.spacing = spacing
        self.containerSize = containerSize
    }
    
    var currentX = 0 as CGFloat
    var currentY = 0 as CGFloat
    var lineHeight = 0 as CGFloat
    
    mutating func add(element size: CGSize) -> CGRect {
        if currentX + size.width > containerSize.width {
            currentX = 0
            currentY += lineHeight + spacing.vertical
            lineHeight = 0
        }
        defer {
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing.horizontal
        }
        return CGRect(origin: CGPoint(x: currentX, y: currentY), size: size)
    }
    
    var size: CGSize {
        return CGSize(width: containerSize.width, height: currentY + lineHeight)
    }
}

