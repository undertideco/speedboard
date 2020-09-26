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
    var style: LaunchableCellStyle = .large
    var isChecked: Bool = false
    
    var handlePressed: ((Action?) -> Void)?
    var onDelete: ((Action) -> Void)?

    var shortcutImageScaleFactor: CGFloat {
        switch style {
        case .small:
            return 0.75
        case .large:
            return 0.6
        }
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            GeometryReader { geo in
                VStack {
                    ZStack {
                        Circle().inset(by: 15).foregroundColor(Color.white)
                        // FIXME: not an ideal implementation for images
                        if let imageData = action.imageData {
                            ShortcutImageView(type: action.type, image: UIImage(data: imageData)!)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: geo.size.width * shortcutImageScaleFactor, alignment: .center)
                        } else {
                            ShortcutImageView(type: action.type, image: UIImage.imageWithColor(color: .clear))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: geo.size.width * shortcutImageScaleFactor, alignment: .center)
                        }
                    }
                    
                    if style == .large {
                        Text(action.actionName ?? "")
                            .font(.system(size: 11))
                    }
                }
                .cellTappable(style: style, color: Color("launchcell_bg"))
                .onTapGesture {
                    self.handlePressed?(self.action)
                }
                .accessibility(addTraits: [.isButton])
                .accessibility(removeTraits: .isImage)
                .accessibility(sortPriority: 1)
            }

        
            if deletable {
                Button(action: {
                    self.onDelete?(self.action)
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 24))
                        .offset(x: -5, y: -5)
                        .onTapGesture {
                            self.onDelete?(self.action)
                        }
                })
                .accessibilityAction(named: Text(Strings.deleteLabel.value), {
                    self.onDelete?(self.action)
                })
                .accessibility(sortPriority: 2)
            }
            
            if isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
                    .offset(x: -5, y: -5)
                    .accessibility(label: Text(Strings.checkedForWidgetLabel.value))
                    .accessibility(sortPriority: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibility(label: Text(action.accessibilityLabel))
        .accessibilityAction {
            self.handlePressed?(action)
        }
    }
}

extension LaunchCell {
    enum Strings {
        case deleteLabel
        case deleteHint(String)
        case checkedForWidgetLabel
        
        var value: LocalizedStringKey {
            switch self {
            case .checkedForWidgetLabel:
                return "LaunchCell_Checked_Label"
            case .deleteLabel:
                return "Accessibility_LaunchCell_Delete_Label"
            case .deleteHint(let actionString):
                return "Accessibility_LaunchCell_Delete_Hint \(actionString)"
            }
        }
    }
}
