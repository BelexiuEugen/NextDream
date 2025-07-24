//
//  NextDreamWidgetLiveActivity.swift
//  NextDreamWidget
//
//  Created by Belexiu Eugeniu on 19/07/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NextDreamWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NextDreamWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextDreamWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NextDreamWidgetAttributes {
    fileprivate static var preview: NextDreamWidgetAttributes {
        NextDreamWidgetAttributes(name: "World")
    }
}

extension NextDreamWidgetAttributes.ContentState {
    fileprivate static var smiley: NextDreamWidgetAttributes.ContentState {
        NextDreamWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NextDreamWidgetAttributes.ContentState {
         NextDreamWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NextDreamWidgetAttributes.preview) {
   NextDreamWidgetLiveActivity()
} contentStates: {
    NextDreamWidgetAttributes.ContentState.smiley
    NextDreamWidgetAttributes.ContentState.starEyes
}
