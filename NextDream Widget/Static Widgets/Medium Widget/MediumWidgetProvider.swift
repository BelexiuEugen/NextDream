//
//  MediumWidgetProvider.swift
//  NextDreamWidgetExtension
//
//  Created by Belexiu Eugeniu on 24/07/2025.
//

import WidgetKit

struct MediumWidgetProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> MediumEntry {
        MediumEntry(date: Date(), taskList: [])
    }

    func snapshot(for configuration: ConfigurationMediumWidget, in context: Context) async -> MediumEntry {
        MediumEntry(date: Date(), taskList: [])
    }
    
    func timeline(for configuration: ConfigurationMediumWidget, in context: Context) async -> Timeline<MediumEntry> {
        var entries: [MediumEntry] = []
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.Person.NextDream")
        let taskList = sharedDefaults?.array(forKey: "widgetMessage") as? [String] ?? []

        entries.append(MediumEntry(date: Date(), taskList: taskList))

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct MediumEntry: TimelineEntry {
    let date: Date
    let taskList: [String]
}

extension MediumEntry{
    static let myArray: [String] = [
        "16 July",
        "27 July",
        "100 July",
        "Maximum Lenght",
        "This another staff",
        "And i Think that's all"
    ]
}
