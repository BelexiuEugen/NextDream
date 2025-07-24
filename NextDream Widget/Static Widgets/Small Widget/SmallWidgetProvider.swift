//
//  SmallWidgetProvider.swift
//  NextDreamWidgetExtension
//
//  Created by Belexiu Eugeniu on 24/07/2025.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationSmallWidget
}

struct SmallWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationSmallWidget())
    }

    func snapshot(for configuration: ConfigurationSmallWidget, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationSmallWidget, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationSmallWidget> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}
