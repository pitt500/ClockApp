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
            LockScreenTimerLiveActivityView(state: context.state)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        TimerControlButton(
                            systemImage: isPaused(context.state) ? "play.fill" : "pause.fill",
                            style: .primary
                        )
                        TimerControlButton(
                            systemImage: "xmark",
                            style: .secondary
                        )
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        Text("Subscribe to @swiftandtips!")
                        Text(formattedRemainingTime(for: context.state, at: .now))
                    }
                }
            } compactLeading: {
                MinimalTimerLiveActivityView(state: context.state)
            } compactTrailing: {
                TimelineView(.animation) { timeline in
                    Text(formattedCompactTrailingTime(for: context.state, at: timeline.date))
                        .monospacedDigit()
                }
            } minimal: {
                MinimalTimerLiveActivityView(state: context.state)
            }
            .keylineTint(.red)
        }
    }

    private func isPaused(_ state: TimerAttributes.ContentState) -> Bool {
        state.status == .paused
    }

    private func remainingInterval(for state: TimerAttributes.ContentState, at date: Date) -> TimeInterval {
        if state.status == .running, let endDate = state.endDate {
            return max(0, endDate.timeIntervalSince(date))
        }

        return max(0, state.remainingWhenNotRunning)
    }

    private func formattedRemainingTime(for state: TimerAttributes.ContentState, at date: Date) -> String {
        let seconds = max(0, Int(remainingInterval(for: state, at: date)))

        if seconds < 60 {
            return "\(seconds) seconds remaining"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes):" + String(format: "%02d", remainingSeconds) + " remaining"
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let remainingSeconds = seconds % 60
            return "\(hours):" + String(format: "%02d:%02d", minutes, remainingSeconds) + " remaining"
        }
    }

    private func formattedCompactTrailingTime(for state: TimerAttributes.ContentState, at date: Date) -> String {
        let seconds = max(0, Int(remainingInterval(for: state, at: date)))

        if seconds < 60 {
            return "\(seconds)"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes):" + String(format: "%02d", remainingSeconds)
        } else {
            let hours = seconds / 3600
            let minutes = (seconds % 3600) / 60
            let remainingSeconds = seconds % 60
            return "\(hours):" + String(format: "%02d:%02d", minutes, remainingSeconds)
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
            totalTimeInterval: 30.5,
            endDate: Date.now.addingTimeInterval(25),
            remainingWhenNotRunning: 0,
            label: "Demo"
        )
    }

    fileprivate static var _120secondsRemaining: TimerAttributes.ContentState {
        TimerAttributes.ContentState(
            status: .running,
            totalTimeInterval: 120.5,
            endDate: Date.now.addingTimeInterval(70),
            remainingWhenNotRunning: 0,
            label: "Demo"
        )
    }
}

#Preview("Notification", as: .content, using: TimerAttributes.preview) {
    TimerLiveActivityConfiguration()
} contentStates: {
    TimerAttributes.ContentState._30secondsRemaining
    TimerAttributes.ContentState._120secondsRemaining
}
