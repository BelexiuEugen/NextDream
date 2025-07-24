//
//  NextDreamMediumWidget.swift
//  NextDreamWidgetExtension
//
//  Created by Belexiu Eugeniu on 22/07/2025.
//

import SwiftUI
import AppIntents
import WidgetKit

struct MediumEntry: TimelineEntry {
    let date: Date
    let taskList: [String]
}

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

struct NextDreamMediumWidget: Widget {
    let myKind: String = "mediumWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: myKind,
            intent: ConfigurationMediumWidget.self,
            provider: MediumWidgetProvider()) { entry in
            NextDreamMediumWidgetEntryView(entry: entry)
                .containerBackground(.white, for: .widget)
        }
        .configurationDisplayName("Medium Widget")
        .description("This will show what task you have today.")
        .supportedFamilies([.systemMedium])
    }
}

struct NextDreamMediumWidgetEntryView: View {
    var entry: MediumEntry
    var taskToShow: Array<String>.SubSequence
    
    init(entry: MediumEntry) {
        self.entry = entry
        taskToShow = entry.taskList.prefix(3)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📝 My Tasks:")
                .font(.headline)
                .foregroundColor(.primary)
            
            if !entry.taskList.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(taskToShow, id: \.self) { task in
                        Text("• \(task)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    
                    if entry.taskList.count > 3 {
                        Text("…and more")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                }
                .padding(.top, 4)
            } else {
                Text("✅ No tasks for today.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }
}

#Preview(as: .systemMedium) {
    NextDreamMediumWidget()
} timeline: {
    MediumEntry(date: .now, taskList: MediumEntry.myArray)
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
