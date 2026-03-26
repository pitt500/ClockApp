//
//  TimerLiveActivityConfiguration.swift
//  TimerLiveActivityConfiguration
//
//  Created by Pedro Rojas on 03/03/26.
//

import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

struct TimerLiveActivityConfiguration: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            LockScreenTimerLiveActivityView(
                state: context.state,
                title: context.attributes.title
            )
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DynamicIslandExpandedLeadingContentView(
                        state: context.state,
                        title: context.attributes.title
                    )
                }

                DynamicIslandExpandedRegion(.center) {
                    DynamicIslandExpandedCenterContentView(
                        state: context.state,
                        title: context.attributes.title
                    )
                }

                DynamicIslandExpandedRegion(.trailing) {
                    DynamicIslandExpandedTrailingContentView(state: context.state)
                }
            } compactLeading: {
                DynamicIslandCompactLeadingContentView(state: context.state)
            } compactTrailing: {
                DynamicIslandCompactTrailingContentView(state: context.state)
            } minimal: {
                DynamicIslandMinimalContentView(state: context.state)
            }
            .keylineTint(.orange)
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
            status: .running,
            totalTimeInterval: 100000.5,
            endDate: Date.now.addingTimeInterval(95000),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(25000),
            presentationMode: .normal
        )
    }

    fileprivate static var _120secondsRemaining: TimerAttributes.ContentState {
        TimerAttributes.ContentState(
            status: .running,
            totalTimeInterval: 120.5,
            endDate: Date.now.addingTimeInterval(70),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(70),
            presentationMode: .normal
        )
    }
}

#Preview("Notification", as: .content, using: TimerAttributes.preview) {
    TimerLiveActivityConfiguration()
} contentStates: {
    TimerAttributes.ContentState._30secondsRemaining
    TimerAttributes.ContentState._120secondsRemaining
}
