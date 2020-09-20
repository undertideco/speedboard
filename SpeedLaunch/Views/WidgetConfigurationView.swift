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
    var actions: [Action] = []
    var selectedIndices: [Int] = []
    var size: WidgetSize = .medium
}

enum WidgetConfigurationAction: Equatable {
    case initialLoad
    case configurationLoadResponse(Result<WidgetConfig, FileReadError>)
    case configurationSaveResponse(Result<Bool, FileWriteError>)
    case updateWidgetActionIndices([Int])
    case setConfigurationWidgetSize(WidgetSize)
}

struct WidgetConfigurationEnvironment {
    
    func fetchActions(for family: WidgetSize) -> Effect<WidgetConfig, FileReadError> {
        let actionsDir: URL = .urlInDocumentsDirectory(with: .storeLocation)
        var selectedIndicesDir: URL
        
        switch family {
        case .medium:
            selectedIndicesDir = .urlInDocumentsDirectory(with: .mediumWidgetActions)
        case .large:
            selectedIndicesDir = .urlInDocumentsDirectory(with: .largeWidgetActions)
        }
        
        do {
            let actionsData = try Data(contentsOf: actionsDir)
            let actions = try JSONDecoder().decode([Action].self, from: actionsData)
            
            var selectedIndices: [Int]
            if FileManager.default.fileExists(atPath: selectedIndicesDir.path) {
                let selectedIndicesData = try Data(contentsOf: selectedIndicesDir)
                selectedIndices = try JSONDecoder().decode([Int].self, from: selectedIndicesData)
            } else {
                selectedIndices = [Int]()
            }
            
            return Effect(value: WidgetConfig(actions: actions, selectedActionIndices: selectedIndices))
        } catch {
            return Effect(error: FileReadError())
        }
    }
    
    func storeActions(indices: [Int], for size: WidgetSize) -> Effect<Bool, FileWriteError> {
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
        state.actions = config.actions
        state.selectedIndices = config.selectedActionIndices
        
        return .none
    case .configurationLoadResponse(.failure(_)):
        return .none
    case .updateWidgetActionIndices(let actionIndices):
        return env.storeActions(indices: actionIndices, for: state.size)
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
    
    init(store: Store<WidgetConfigurationState, WidgetConfigurationAction>) {
      self.viewStore = ViewStore(store)
    }
        
    var body: some View {
        VStack {
            Text("Select Actions To Enable for Widget")
                .font(.system(size: 18, weight: .bold, design: .default))
            Picker("Picker Size",
                   selection: viewStore.binding(
                    get: \.size,
                    send: WidgetConfigurationAction.setConfigurationWidgetSize
                   )) {
                Text("Medium").tag(WidgetSize.medium)
                Text("Large").tag(WidgetSize.large)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.leading, .trailing], 8)
            
            QGrid(viewStore.actions, columns: 4) { action in
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
        }
    }

    func handleCellPressed(_ action: Action?) {
        guard let action = action,
              let actionIndex = viewStore.actions.firstIndex(of: action) else { return }
        if isChecked(viewStore, action: action) {
            let filteredIndices = viewStore.selectedIndices.filter { $0 != actionIndex }
            viewStore.send(.updateWidgetActionIndices(filteredIndices))
        } else {
            let newIndices = viewStore.selectedIndices + [actionIndex]
            viewStore.send(.updateWidgetActionIndices(newIndices))
        }
    }

    func isChecked(_ store: ViewStore<WidgetConfigurationState, WidgetConfigurationAction>, action: Action) -> Bool {
        guard let actionIndex = store.actions.firstIndex(of: action) else { return false }
        
        return store.selectedIndices.contains(actionIndex)
    }
}

//struct WidgetConfigurationView_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetConfigurationView(
//            actions: [Action(type: .empty, position: 0, phoneNumber: "96678108", imageUrl: nil)],
//            selectedPicker: .constant(.medium),
//            selectedIndices: .constant([0])
//        )
//    }
//}
