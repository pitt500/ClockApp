//
//  TimerLiveActivityLiveActivity.swift
//  TimerLiveActivity
//
//  Created by Pedro Rojas on 03/03/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            // Lock screen/banner UI goes here
            LockScreenTimerLiveActivityView(state: context.state)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        TimerControlButton(
                            systemImage: context.state.isPaused ? "play.fill" : "pause.fill",
                            style: .primary
                        )
                        TimerControlButton(
                            systemImage: "xmark",
                            style: .secondary
                        )
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text("Subscribe to @swiftandtips!")
                        Text("\(context.state.remainingTime.components.seconds) seconds remaining")
                    }
                    // more content
                }
            } compactLeading: {
                MinimalTimerLiveActivityView(state: context.state)
            } compactTrailing: {
                Text("\(context.state.remainingTime.components.seconds) secs")
            } minimal: {
                MinimalTimerLiveActivityView(state: context.state)
            }
            //.widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TimerAttributes {
    fileprivate static var preview: TimerAttributes {
        TimerAttributes(title: "Demo")
    }
}

extension TimerAttributes.ContentState {
    fileprivate static var _30secondsRemaining: TimerAttributes.ContentState {
        TimerAttributes.ContentState(
            remainingTime: .seconds(25),
            totalTime: .seconds(30),
            isPaused: false
        )
     }
     
     fileprivate static var _120secondsRemaining: TimerAttributes.ContentState {
         TimerAttributes.ContentState(
            remainingTime: .seconds(70),
            totalTime: .seconds(120),
            isPaused: false
         )
     }
}

#Preview("Notification", as: .content, using: TimerAttributes.preview) {
    TimerLiveActivityConfiguration()
} contentStates: {
    TimerAttributes.ContentState._30secondsRemaining
    TimerAttributes.ContentState._120secondsRemaining
}
