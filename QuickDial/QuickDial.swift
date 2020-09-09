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
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), actionsStore: Store(initialState: WidgetState(), reducer: widgetReducer, environment: WidgetEnvironment()))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), actionsStore: Store(initialState: WidgetState(), reducer: widgetReducer, environment: WidgetEnvironment()))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date(), actionsStore: Store(initialState: WidgetState(), reducer: widgetReducer, environment: WidgetEnvironment()))
        
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
        case .systemMedium, .systemLarge:
            return [
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
        case .systemSmall:
            return 4
        case .systemMedium:
            return 6
        case .systemLarge:
            return 9
        default:
            return 1
        }
    }
    
    var actionsToDisplay: [Action] {
        if actions.count >= numberOfItems {
            return actions
        } else {
            var actionsToReturn = actions
            actionsToReturn.append(Action(type: .empty, position: 999, phoneNumber: nil, imageUrl: nil))
            return actionsToReturn
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: columns) {
                ForEach(actionsToDisplay, id: \.self) { action  in
                    Link(destination: action.generateURLLaunchSchemeString()!) {
                        if action.type == .empty {
                            EmptyLaunchCell()
                                .actionResizable(geo: geo, rows: numberOfItems/columns.count, cols: columns.count)
                        } else {
                            LaunchCell(deletable: .constant(false),
                                       action: action)
                                .actionResizable(geo: geo, rows: numberOfItems/columns.count, cols: columns.count)
                        }
                    }
                }
            }
        }.padding(4)
    }
}

@main
struct QuickDial: Widget {
    let kind: String = "QuickDial"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "co.undertide.speedboard", provider: Provider(), content: { entry in
            WithViewStore(entry.actionsStore) { viewStore in
                QuickDialEntryView(entry: entry, actions: viewStore.actions ?? [])
                    .padding(8)
                    .onAppear {
                        viewStore.send(.initialLoad)
                    }
            }
        })
        .configurationDisplayName("Quick Actions")
        .description("Dial without opening the app")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
