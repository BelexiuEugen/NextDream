//
//  NextDreamWidget.swift
//  NextDreamWidget
//
//  Created by Belexiu Eugeniu on 19/07/2025.
//

import WidgetKit
import SwiftUI

struct NextDreamSmallWidgetEntryView : View {
    var entry: SmallWidgetProvider.Entry

    var body: some View {
        VStack(spacing: 4) {
            Text("Streak")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(entry.configuration.streakCount)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        
    }
}

struct NextDreamSmallWidget: Widget {
    let kind: String = "NextDreamWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationSmallWidget.self, provider: SmallWidgetProvider()) { entry in
            NextDreamSmallWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)

        }
        .configurationDisplayName("Test")
        .description("just a simple description for my widget")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    NextDreamSmallWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
//    SimpleEntry(date: .now, configuration: .starEyes)
}
