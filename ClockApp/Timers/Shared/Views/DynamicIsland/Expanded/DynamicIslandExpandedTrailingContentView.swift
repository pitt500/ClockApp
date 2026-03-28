//
//  DynamicIslandExpandedTrailingTimerView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 26/03/26.
//

import SwiftUI
import AppIntents

struct DynamicIslandExpandedTrailingTimerView: View {
    let state: TimerAttributes.ContentState

    var body: some View {
        if isAlerting {
            Button(intent: DismissTimerAlertIntent()) {
                TimerControlButton(
                    systemImage: "xmark",
                    style: .secondary
                )
            }
            .buttonStyle(.plain)
        } else {
            expandedTrailingRemainingTimeView
        }
    }

    @ViewBuilder
    private var remainingTimeView: some View {
        if let timerInterval = state.runningTimeInterval {
            Text(
                timerInterval: timerInterval,
                pauseTime: nil,
                countsDown: true,
                showsHours: showsHours
            )
        } else {
            Text(formattedPausedTime)
        }
    }

    @ViewBuilder
    private var expandedTrailingRemainingTimeView: some View {
        if state.runningTimeInterval != nil {
            remainingTimeView
                .font(.body.scaled(by: 3.0))
                .monospacedDigit()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.trailing)
                .frame(maxHeight: .infinity, alignment: .center)
        } else {
            Text(formattedPausedTime)
                .font(.body.scaled(by: 3.0))
                .monospacedDigit()
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .foregroundStyle(.orange)
                .multilineTextAlignment(.trailing)
                .frame(maxHeight: .infinity, alignment: .center)
        }
    }

    private var isAlerting: Bool {
        state.presentationMode == .alerting
    }

    private var showsHours: Bool {
        let seconds = Int(max(0, state.totalTimeInterval))
        return seconds >= 3600
    }

    private var formattedPausedTime: String {
        LiveActivityTimerFormatting.formattedDisplayTime(state.displayedRemainingTime)
    }
}
