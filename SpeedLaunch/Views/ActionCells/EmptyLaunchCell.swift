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
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .foregroundColor(Color("primary"))
                    Image(systemName: "plus")
                        .font(.system(size: geo.size.height * 0.5, weight: .regular, design: .default))
                        .foregroundColor(.white)
                }.padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            }
            
            if displayString != nil {
                Text("\(displayString!)")
                    .foregroundColor(Color("primaryText"))
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
        EmptyLaunchCell(displayString: "New action")
            .frame(width: 100, height: 100, alignment: .center)
    }
}
