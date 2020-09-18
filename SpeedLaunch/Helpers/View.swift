//
//  View.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/17/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        }
        else {
            self
        }
    }
}
