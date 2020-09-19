//
//  WidgetConfigurationView.swift
//  SpeedLaunch
//
//  Created by Jurvis Tan on 9/14/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import SwiftUI
import QGrid
import ComposableArchitecture

struct WidgetConfigurationView: View {
    var actions: [Action]
    @Binding var selectedPicker: WidgetSize
    @Binding var selectedIndices: [Int]
        
    var body: some View {
        VStack {
            Text("Select Actions To Enable for Widget")
                .font(.system(size: 18, weight: .bold, design: .default))
            Picker("Picker Size", selection: $selectedPicker) {
                Text("Medium").tag(WidgetSize.medium)
                Text("Large").tag(WidgetSize.large)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing], 8)
            
            QGrid(actions, columns: 4) { action in
                Group {
                    if action.type != .empty {
                        LaunchCell(deletable: .constant(false),
                                   action: action,
                                   style: .small,
                                   isChecked: isChecked(action),
                                   handlePressed: handleCellPressed)
                            .frame(width: 75, height: 75, alignment: .center)
                            .padding(5)
                    }
                }
            }
        }
    }
    
    func handleCellPressed(_ action: Action?) {
        guard let action = action,
              let actionIndex = actions.firstIndex(of: action) else { return }
        if isChecked(action) {
            selectedIndices = selectedIndices.filter { $0 != actionIndex }
        } else {
            selectedIndices.append(actionIndex)
        }
    }
    
    func isChecked(_ action: Action) -> Bool {
        guard let actionIndex = actions.firstIndex(of: action) else { return false }
        return selectedIndices.contains(actionIndex)
    }
}

struct WidgetConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetConfigurationView(
            actions: [Action(type: .empty, position: 0, phoneNumber: "96678108", imageUrl: nil)],
            selectedPicker: .constant(.medium),
            selectedIndices: .constant([0])
        )
    }
}
