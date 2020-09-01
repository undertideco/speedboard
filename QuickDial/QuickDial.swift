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
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, actionsStore: Store(initialState: WidgetState(), reducer: widgetReducer, environment: WidgetEnvironment()))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
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
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(actions.dropLast()) { action  in
                    LaunchCell(deletable: .constant(false),
                               action: action)
                        .actionResizable(geo: geo, rows: numberOfItems/columns.count, cols: columns.count)
                        .widgetURL(action.generateURLLaunchSchemeString())
                }
            }
        }
    }
}

@main
struct QuickDial: Widget {
    let kind: String = "QuickDial"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "co.undertide.speedboard", provider: Provider(), content: { entry in
            WithViewStore(entry.actionsStore) { viewStore in
                QuickDialEntryView(entry: entry, actions: viewStore.actionsToDisplay)
                    .padding(8)
            }
        })
        .configurationDisplayName("Quick Actions")
        .description("Dial without opening the app")
    }
}
