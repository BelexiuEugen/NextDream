//
//  AppIntent.swift
//  NextDreamWidget
//
//  Created by Belexiu Eugeniu on 19/07/2025.
//

import WidgetKit
import AppIntents

// MARK: SMALL Configuration

struct ConfigurationSmallWidget: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
//    static var description: IntentDescription { "This is an example widget." }

    
    @Parameter(title: "Streak Count", default: 0)
    var streakCount: Int
}

extension ConfigurationSmallWidget {
    static var smiley: ConfigurationSmallWidget {
        let intent = ConfigurationSmallWidget()
//        intent.favoriteEmoji = "😀"
        intent.streakCount = 12
        return intent
    }
    
    static var starEyes: ConfigurationSmallWidget {
        let intent = ConfigurationSmallWidget()
        intent.streakCount = 100
        return intent
    }
}


