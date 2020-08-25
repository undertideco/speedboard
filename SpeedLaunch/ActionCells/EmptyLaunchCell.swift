//
//  EmptyLaunchCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 25/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct EmptyLaunchCell: View, Launchable {    
    var handlePressed: ((()) -> Void)?
    
    var body: some View {
        ZStack {
            Circle().inset(by: 15).foregroundColor(.lightBlue)
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .regular, design: .default))
                .foregroundColor(.white)
        }
        .onTapGesture {
            self.handlePressed?(())
        }
    }
}

struct EmptyLaunchCell_Previews: PreviewProvider {
    static var previews: some View {
        EmptyLaunchCell()
            .frame(width: 100, height: 100, alignment: .center)
    }
}
