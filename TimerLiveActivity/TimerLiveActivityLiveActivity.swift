//
//  TimerLiveActivityLiveActivity.swift
//  TimerLiveActivity
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
            LockScreenTimerLiveActivityView(state: context.state)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Button(intent: PauseOrResumeTimerIntent()) {
                            TimerControlButton(
                                systemImage: isPaused(context.state) ? "play.fill" : "pause.fill",
                                style: .primary
                            )
                        }
                        .buttonStyle(.plain)

                        Button(intent: CancelTimerIntent()) {
                            TimerControlButton(
                                systemImage: "xmark",
                                style: .secondary
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    #warning("Fix this")
                    VStack(spacing: 6) {
                        Text("Subscribe to @swiftandtips!")
                        remainingTimeView(for: context.state)
                    }
                }
            } compactLeading: {
                MinimalTimerLiveActivityView(state: context.state)
            } compactTrailing: {
                compactTrailingRemainingTimeView(for: context.state)
            } minimal: {
                MinimalTimerLiveActivityView(state: context.state)
            }
            .keylineTint(.red)
        }
    }

    private func isPaused(_ state: TimerAttributes.ContentState) -> Bool {
        state.status == .paused
    }

    @ViewBuilder
    private func remainingTimeView(for state: TimerAttributes.ContentState) -> some View {
        if let timerInterval = state.runningTimeInterval {
            Text(
                timerInterval: timerInterval,
                pauseTime: nil,
                countsDown: true,
                showsHours: showsHours(for: state)
            )
        } else {
            Text(formattedPausedTime(for: state))
        }
    }

    @ViewBuilder
    private func compactTrailingRemainingTimeView(
        for state: TimerAttributes.ContentState
    ) -> some View {
        let placeholder = placeholderFormat(for: state)

        if let timerInterval = state.runningTimeInterval {
            Text(placeholder)
                .hidden()
                .overlay(alignment: .leading) {
                    Text(
                        timerInterval: timerInterval,
                        pauseTime: nil,
                        countsDown: true,
                        showsHours: showsHours(for: state)
                    )
                    .monospacedDigit()
                    .lineLimit(1)
                }
        } else {
            Text(placeholder)
                .hidden()
                .overlay(alignment: .leading) {
                    Text(formattedPausedTime(for: state))
                        .monospacedDigit()
                        .lineLimit(1)
                }
        }
    }

    /*
     This placeholder is required because Text(timerInterval:) expands to the maximum possible width of its content in the Dynamic Island, causing layout issues. By providing a fixed-width placeholder (e.g. “00:00” or “00:00:00”) and overlaying the real timer on top, we ensure the layout remains stable and only occupies the necessary space.
    */
    private func placeholderFormat(for state: TimerAttributes.ContentState) -> String {
        showsHours(for: state) ? "00:00:00" : "00:00"
    }

    private func showsHours(for state: TimerAttributes.ContentState) -> Bool {
        let seconds = Int(max(0, state.totalTimeInterval))
        return seconds >= 3600
    }

    private func formattedPausedTime(for state: TimerAttributes.ContentState) -> String {
        LiveActivityTimerFormatting.formattedDisplayTime(state.displayedRemainingTime)
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
            totalTimeInterval: 30000.5,
            endDate: Date.now.addingTimeInterval(25000),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(25000),
            label: "Demo"
        )
    }

    fileprivate static var _120secondsRemaining: TimerAttributes.ContentState {
        TimerAttributes.ContentState(
            status: .running,
            totalTimeInterval: 120.5,
            endDate: Date.now.addingTimeInterval(70),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(70),
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
