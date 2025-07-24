//
//  NextDreamMediumWidget.swift
//  NextDreamWidgetExtension
//
//  Created by Belexiu Eugeniu on 22/07/2025.
//

import SwiftUI
import AppIntents
import WidgetKit


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
            headline
            
            if !entry.taskList.isEmpty {
                todayTasks
            } else {
                noTasksForToday
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

extension NextDreamMediumWidgetEntryView{
    
    private var headline: some View{
        Text("📝 My Tasks:")
            .font(.headline)
            .foregroundColor(.primary)
    }
    
    private var todayTasks: some View{
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
    }
    
    private var noTasksForToday: some View{
        Text("✅ No tasks for today.")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.top, 4)
    }
}
