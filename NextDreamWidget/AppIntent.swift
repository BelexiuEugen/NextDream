//
//  AppIntent.swift
//  NextDreamWidget
//
//  Created by Belexiu Eugeniu on 19/07/2025.
//

import WidgetKit
import AppIntents

// MARK: SMALL Configuration

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
//    static var description: IntentDescription { "This is an example widget." }

    
    @Parameter(title: "Streak Count", default: 0)
    var streakCount: Int
}

// MARK: Medium Configuration

struct ConfigurationMediumWidget: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Medium Widget Configuration" }
//    static var description: IntentDescription { "This is an example widget." }

    
//    @Parameter(title: "Today Task", default: [])
//    var taskForToday: [String]
}

extension ConfigurationAppIntent {
    static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
        intent.streakCount = 12
        return intent
    }
    
    static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.streakCount = 100
        return intent
    }
}


