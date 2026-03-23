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
            LockScreenTimerLiveActivityView(state: context.state)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    #warning("Create subviews to refactor this code.")
                    if isAlerting(context.state) {
                        Text(context.attributes.title)
                            .font(.body.scaled(by: 1.8).bold())
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    } else {
                        HStack(spacing: 12) {
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
                }

                DynamicIslandExpandedRegion(.center) {
                    #warning("avoid system font size")
                    if !isAlerting(context.state) {
                        Text(context.attributes.title)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.orange)
                            .lineLimit(1)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if isAlerting(context.state) {
                        Button(intent: DismissTimerAlertIntent()) {
                            TimerControlButton(
                                systemImage: "xmark",
                                style: .secondary
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        expandedTrailingRemainingTimeView(for: context.state)
                    }
                }
            } compactLeading: {
                if isAlerting(context.state) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.orange)
                } else {
                    MinimalTimerLiveActivityView(state: context.state)
                }
            } compactTrailing: {
                if isAlerting(context.state) {
                    EmptyView()
                } else {
                    compactTrailingRemainingTimeView(for: context.state)
                }
            } minimal: {
                if isAlerting(context.state) {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(.orange)
                } else {
                    MinimalTimerLiveActivityView(state: context.state)
                }
            }
            .keylineTint(.orange)
        }
    }

    private func isPaused(_ state: TimerAttributes.ContentState) -> Bool {
        state.status == .paused
    }

    private func isAlerting(_ state: TimerAttributes.ContentState) -> Bool {
        state.presentationMode == .alerting
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
    private func expandedTrailingRemainingTimeView(
        for state: TimerAttributes.ContentState
    ) -> some View {
        if state.runningTimeInterval != nil {
            remainingTimeView(for: state)
                .font(.body.scaled(by: 3.0))
                .monospacedDigit()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.trailing)
                .frame(maxHeight: .infinity, alignment: .center)
        } else {
            Text(formattedPausedTime(for: state))
                .font(.body.scaled(by: 3.0))
                .monospacedDigit()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.trailing)
                .frame(maxHeight: .infinity, alignment: .center)
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
     This placeholder is required because Text(timerInterval:) expands to the maximum possible width of its content in the Dynamic Island, causing layout issues. By providing a fixed-width placeholder (e.g. "00:00" or "00:00:00") and overlaying the real timer on top, we ensure the layout remains stable and only occupies the necessary space.
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
