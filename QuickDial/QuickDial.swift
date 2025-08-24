//
//  QuickDial.swift
//  QuickDial
//
//  Created by Jurvis Tan on 8/31/20.
//  Copyright © 2020 Undertide LLP. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import ComposableArchitecture

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry
    
    var storageClient: StorageClient {
        return CommandLine.arguments.contains("--load-local") ? .mock : .live
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), actionsStore: Store(initialState: WidgetState()) { WidgetReducer() })
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), actionsStore: Store(initialState: WidgetState()) { WidgetReducer() })
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date(), actionsStore: Store(initialState: WidgetState()) { WidgetReducer() })

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let actionsStore: Store<WidgetState, WidgetAction>
}

struct QuickDialEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    let actions: [Action]
    
    @State var pressedURL: URL? = nil
    
    var columns: [GridItem] {
        switch family {
        case .systemSmall:
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        case .systemMedium:
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
        case .systemLarge:
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ]
        default:
            return [GridItem(.flexible())]
        }
    }
    
    var numberOfItems: Int {
        switch family {
        case .systemMedium:
            return WidgetSize.medium.maxNumberOfActions
        case .systemLarge:
            return WidgetSize.large.maxNumberOfActions
        default:
            return 1
        }
    }
    
    var actionsToDisplay: [Action] {
        if actions.count >= numberOfItems {
            return actions
        } else {
            var actionsToReturn = actions
            actionsToReturn.append(
                Action(
                    id: UUID(),
                    type: .empty,
                    contactValue: nil,
                    imageData: nil,
                    createdTime: Date()
                )
            )
            return actionsToReturn
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: columns) {
                ForEach(actionsToDisplay, id: \.self) { action  in
                    Link(destination: action.generateURLLaunchSchemeString() ?? URL(string: "speedboard://")!) {
                        if action.type == .empty {
                            EmptyLaunchCell(style: .small)
                                .actionResizable(geo: geo, rows: numberOfItems/columns.count, cols: columns.count)
                        } else {
                            LaunchCell(deletable: .constant(false),
                                       action: action, style: .small)
                                .actionResizable(geo: geo, rows: numberOfItems/columns.count, cols: columns.count)
                        }
                    }
                }
            }
        }
    }
}

extension QuickDial {
    enum Strings: LocalizedStringKey {
        case displayName = "Widget_DisplayName"
        case widgetDescription = "Widget_Description"
    }
}

@main
struct QuickDial: Widget {
    let kind: String = "QuickDial"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "co.undertide.speedboard", provider: Provider()) { entry in
            WithViewStore(entry.actionsStore, observe: { $0 }) { viewStore in
                QuickDialEntryView(entry: entry, actions: viewStore.actions ?? [])
                    .padding([.bottom, .leading, .trailing], 16)
                    .padding([.top], 8)
                    .onAppear {
                        viewStore.send(.initialLoad)
                    }
            }
        }
        .configurationDisplayName(Strings.displayName.rawValue)
        .description(Strings.widgetDescription.rawValue)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
