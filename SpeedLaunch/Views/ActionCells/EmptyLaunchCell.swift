//
//  EmptyLaunchCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 25/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct EmptyLaunchCell: View, Launchable {
    var displayString: String? = nil
    var handlePressed: ((()) -> Void)?
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(.primary)
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .regular, design: .default))
                    .foregroundColor(.white)
            }.padding(EdgeInsets(top: 9, leading: 20, bottom: 5, trailing: 20))
            
            if displayString != nil {
                Text("\(displayString!)")
                    .font(.system(size: 11))
            }
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
