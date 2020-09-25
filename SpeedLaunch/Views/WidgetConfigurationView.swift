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

struct WidgetConfigurationState: Equatable {
    var selectedIds: [String] = []
    var size: WidgetSize = .medium
}

enum WidgetConfigurationAction: Equatable {
    case initialLoad
    case configurationLoadResponse(Result<WidgetConfig, FileReadError>)
    case configurationSaveResponse(Result<Bool, FileWriteError>)
    case updateWidgetActionIds([String])
    case setConfigurationWidgetSize(WidgetSize)
}

struct WidgetConfigurationEnvironment {
    
    func fetchActions(for family: WidgetSize) -> Effect<WidgetConfig, FileReadError> {
        let actionsDir: URL = .urlInDocumentsDirectory(with: .storeLocation)
        var selectedIdsDir: URL
        
        switch family {
        case .medium:
            selectedIdsDir = .urlInDocumentsDirectory(with: .mediumWidgetActions)
        case .large:
            selectedIdsDir = .urlInDocumentsDirectory(with: .largeWidgetActions)
        }
        
        do {
            let actionsData = try Data(contentsOf: actionsDir)
            let actions = try JSONDecoder().decode([Action].self, from: actionsData)
            
            var selectedIds: [String]
            if FileManager.default.fileExists(atPath: selectedIdsDir.path) {
                let selectedIndicesData = try Data(contentsOf: selectedIdsDir)
                selectedIds = try JSONDecoder().decode([String].self, from: selectedIndicesData)
            } else {
                selectedIds = [String]()
            }
            
            return Effect(value: WidgetConfig(actions: actions, selectedActionIds: selectedIds))
        } catch {
            return Effect(error: FileReadError())
        }
    }
    
    func storeActions(indices: [String], for size: WidgetSize) -> Effect<Bool, FileWriteError> {
        var selectedIndicesDir: URL
        
        switch size {
        case .medium:
            selectedIndicesDir = .urlInDocumentsDirectory(with: .mediumWidgetActions)
        case .large:
            selectedIndicesDir = .urlInDocumentsDirectory(with: .largeWidgetActions)
        }
        
        do {
            let data = try JSONEncoder().encode(indices)
            try data.write(to: selectedIndicesDir)
            
            return Effect(value: true)
        } catch {
            print("Unable to save")
            return Effect(error: FileWriteError())
        }
    }
}

let widgetConfigReducer = Reducer<WidgetConfigurationState, WidgetConfigurationAction, WidgetConfigurationEnvironment> { state, action, env in
    switch action  {
    case .initialLoad:
        return env.fetchActions(for: state.size)
            .catchToEffect()
            .map(WidgetConfigurationAction.configurationLoadResponse)
            .eraseToEffect()
    case let .configurationLoadResponse(.success(config)):
        state.selectedIds = config.selectedActionIds
        
        return .none
    case .configurationLoadResponse(.failure(_)):
        return .none
    case .updateWidgetActionIds(let actionIds):
        state.selectedIds = actionIds
        
        return env.storeActions(indices: actionIds, for: state.size)
            .catchToEffect()
            .map(WidgetConfigurationAction.configurationSaveResponse)
            .eraseToEffect()
    case .configurationSaveResponse(_):
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadTimelines(ofKind: "co.undertide.speedboard")
        }
        return .none
    case .setConfigurationWidgetSize(let size):
        state.size = size
        return env.fetchActions(for: state.size)
            .catchToEffect()
            .map(WidgetConfigurationAction.configurationLoadResponse)
            .eraseToEffect()
    }

}

struct WidgetConfigurationView: View {
    @ObservedObject var viewStore: ViewStore<WidgetConfigurationState, WidgetConfigurationAction>
    var actions: [Action]
    @State var showMaxNumberAlert: Bool = false
    
    init(store: Store<WidgetConfigurationState, WidgetConfigurationAction>, actions: [Action]) {
        self.viewStore = ViewStore(store)
        self.actions = actions
    }
        
    var body: some View {
        VStack {
            Text(Strings.title.rawValue)
                .font(.system(size: 18, weight: .bold, design: .default))
            Picker(Strings.pickerTitle.rawValue,
                   selection: viewStore.binding(
                    get: \.size,
                    send: WidgetConfigurationAction.setConfigurationWidgetSize
                   )) {
                Text("Medium")
                    .tag(WidgetSize.medium)
                Text("Large")
                    .tag(WidgetSize.large)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing], 8)
            
            QGrid(actions, columns: 4) { action in
                Group {
                    if action.type != .empty {
                        LaunchCell(deletable: .constant(false),
                                   action: action,
                                   style: .small,
                                   isChecked: isChecked(viewStore, action: action),
                                   handlePressed: handleCellPressed)
                            .frame(width: 75, height: 75, alignment: .center)
                            .padding(5)
                    }
                }
            }
        }.onAppear {
            viewStore.send(.initialLoad)
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
        guard let action = action else { return }
        if isChecked(viewStore, action: action) {
            let filteredIndices = viewStore.selectedIds.filter { $0 != action.id }
            viewStore.send(.updateWidgetActionIds(filteredIndices))
        } else {
            if viewStore.selectedIds.count == viewStore.size.maxNumberOfActions {
                showMaxNumberAlert = true
            } else {
                let newIds = viewStore.selectedIds + [action.id]
                viewStore.send(.updateWidgetActionIds(newIds))
            }

        }
    }

    func isChecked(_ store: ViewStore<WidgetConfigurationState, WidgetConfigurationAction>, action: Action) -> Bool {
        return viewStore.selectedIds.contains(action.id)
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
