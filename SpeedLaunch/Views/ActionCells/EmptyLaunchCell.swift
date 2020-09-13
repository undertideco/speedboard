//
//  EmptyLaunchCell.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 25/8/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI

struct EmptyLaunchCell: View, Launchable {
    var style: LaunchableCellStyle = .large
    
    var localizedString: LocalizedStringKey? = nil
    var displayString: String? = nil
    
    var handlePressed: ((()) -> Void)?
    
    var scaleFactor: CGFloat {
        switch style {
        case .small:
            return 0.7
        case .large:
            return 0.8
        }
    }
    
    init(localizedString: LocalizedStringKey?,
         handlePressed: ((()) -> Void)?) {
        self.localizedString = localizedString
        self.handlePressed = handlePressed
    }
    
    init(style: LaunchableCellStyle,
         displayString: String? = nil,
         handlePressed: ((()) -> Void)? = nil) {
        self.style = style
        self.displayString = displayString
        self.handlePressed = handlePressed
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                PlusView()
                    .scaleEffect(scaleFactor)
                if displayString != nil || localizedString != nil {
                    Text(localizedString ?? "\(displayString ?? "")")
                        .foregroundColor(Color("primaryText"))
                        .font(.system(size: 11))
                }
            }
            .cellTappable(style: style, color: .clear)
            .onTapGesture {
                self.handlePressed?(())
            }
        }
       
    }
}

struct PlusView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                Circle()
                    .foregroundColor(Color("primary"))
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.system(size: geo.size.height * 0.45))
            }
        }

    }
}

struct EmptyLaunchCell_Previews: PreviewProvider {
    static var previews: some View {
        EmptyLaunchCell(style: .small, displayString: "New action")
            .frame(width: 100, height: 100, alignment: .center)
    }
}
