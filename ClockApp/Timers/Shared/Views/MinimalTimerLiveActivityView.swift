//
//  MinimalTimerLiveActivityView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI
import WidgetKit

struct MinimalTimerLiveActivityView: View {
    let state: TimerAttributes.ContentState
    
    #warning("Review Paused State")
    var body: some View {
        if let timerInterval {
            ProgressView(
                timerInterval: timerInterval,
                countsDown: true
            ) {
                EmptyView()
            } currentValueLabel: {
                EmptyView()
            }
            .progressViewStyle(.circular)
            .tint(.orange)
            .frame(
                width: ClockTimerStyle.activityRingSize,
                height: ClockTimerStyle.activityRingSize
            )
        } else {
            ProgressView(value: pausedProgress, total: 1.0)
                .progressViewStyle(.circular)
                .tint(.orange)
                .frame(
                    width: ClockTimerStyle.activityRingSize,
                    height: ClockTimerStyle.activityRingSize
                )
        }
    }

#warning("Review this later")
    private var timerInterval: ClosedRange<Date>? {
        guard state.status == .running, let endDate = state.endDate else { return nil }
        let startDate = endDate.addingTimeInterval(-state.totalTimeInterval)
        return startDate...endDate
    }

    #warning("Review this later")
    private var pausedProgress: Double {
        let total = max(1.0, state.totalTimeInterval)
        let remaining = max(0, state.remainingWhenNotRunning)
        return remaining / total
    }
}

#Preview {
    MinimalTimerLiveActivityView(
        state: .init(
            status: .running,
            totalTimeInterval: 30.5,
            endDate: Date.now.addingTimeInterval(25),
            remainingWhenNotRunning: 0,
            label: "Preview"
        )
    )
    .frame(width: 100, height: 100)
}
