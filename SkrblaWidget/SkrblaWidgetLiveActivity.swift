//
//  SkrblaWidgetLiveActivity.swift
//  SkrblaWidget
//
//  Created by Michal Hájek on 11.09.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SkrblaWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SkrblaWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SkrblaWidgetAttributes.self) { context in
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

extension SkrblaWidgetAttributes {
    fileprivate static var preview: SkrblaWidgetAttributes {
        SkrblaWidgetAttributes(name: "World")
    }
}

extension SkrblaWidgetAttributes.ContentState {
    fileprivate static var smiley: SkrblaWidgetAttributes.ContentState {
        SkrblaWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SkrblaWidgetAttributes.ContentState {
         SkrblaWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SkrblaWidgetAttributes.preview) {
   SkrblaWidgetLiveActivity()
} contentStates: {
    SkrblaWidgetAttributes.ContentState.smiley
    SkrblaWidgetAttributes.ContentState.starEyes
}
