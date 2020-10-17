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
import WidgetKit

enum WidgetConfigurationAction: Equatable {
    case updateAction(Action)
    case didUpdateAction(Result<Action, PersistenceError>)
}

struct WidgetConfigurationEnvironment {    
    var storageClient: StorageClient
}

let widgetConfigReducer = Reducer<[Action], WidgetConfigurationAction, WidgetConfigurationEnvironment> { state, action, env in
    switch action  {
    case .updateAction(let action):
        return env.storageClient.updateWidgetPreferences(action)
            .catchToEffect()
            .map(WidgetConfigurationAction.didUpdateAction)
            .eraseToEffect()
    case .didUpdateAction(_):
        return .none
    }

}

struct WidgetConfigurationView: View {
    @ObservedObject var viewStore: ViewStore<[Action], WidgetConfigurationAction>
    @State var size: WidgetSize = .medium
    @State var showMaxNumberAlert: Bool = false
    
    var actionCellDimension: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone{
            return 75
        } else {
            return 112.5
        }
    }
    
    init(store: Store<[Action], WidgetConfigurationAction>, actions: [Action]) {
        self.viewStore = ViewStore(store)
    }
        
    var body: some View {
        VStack {
            Text(Strings.title.rawValue)
                .font(.system(size: 18, weight: .bold, design: .default))
            Picker(Strings.pickerTitle.rawValue,
                   selection: $size) {
                Text("Medium")
                    .tag(WidgetSize.medium)
                Text("Large")
                    .tag(WidgetSize.large)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing], 8)
            
            QGrid(viewStore.state, columns: 4) { action in
                Group {
                    if action.type != .empty {
                        LaunchCell(deletable: .constant(false),
                                   action: action,
                                   style: .small,
                                   isChecked: isChecked(action: action),
                                   handlePressed: handleCellPressed)
                            .frame(width: actionCellDimension,
                                   height: actionCellDimension,
                                   alignment: .center)
                            .padding(5)
                    }
                }
            }
        }.alert(isPresented: $showMaxNumberAlert) {
            Alert(
                title: Text(Strings.maxActionsAlertTitle.rawValue),
                message: Text(Strings.maxActionsAlertMessage.rawValue),
                dismissButton: .default(
                    Text(Strings.maxActionsAlertAction.rawValue)
                )
            )
        }
    }
    

    func handleCellPressed(_ action: Action?) {
        guard var action = action else { return }
        
        switch size {
        case .medium:
            action.isMediumWidgetDisplayable.toggle()
            viewStore.send(.updateAction(action))
        case .large:
            action.isLargeWidgetDisplayable.toggle()
            viewStore.send(.updateAction(action))
        }
        
    }

    func isChecked(action: Action) -> Bool {
        switch size {
        case .medium:
            return action.isMediumWidgetDisplayable
        case .large:
            return action.isLargeWidgetDisplayable
        }
    }
}

extension WidgetConfigurationView {
    enum Strings: LocalizedStringKey {
        case title = "SlideoverCard_Title"
        case pickerTitle = "SlideoverCard_PickerTitle"
        case widgetSizeMed = "SlideoverCard_Size_Med"
        case widgetSizeLg = "SlideoverCard_Size_Lg"
        
        case maxActionsAlertTitle = "SlideoverCard_MaxActionsTitle"
        case maxActionsAlertMessage = "SlideoverCard_MaxActionsMessage"
        case maxActionsAlertAction = "SlideoverCard_DismissAction"
    }
}
