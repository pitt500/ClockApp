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
    
    var body: some View {
        if let timerInterval = state.runningTimeInterval {
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
            ProgressView(value: state.progressSnapshot.progress(at: .now), total: 1.0)
                .progressViewStyle(.circular)
                .tint(.orange)
                .frame(
                    width: ClockTimerStyle.activityRingSize,
                    height: ClockTimerStyle.activityRingSize
                )
        }
    }
}

#Preview {
    MinimalTimerLiveActivityView(
        state: .init(
            status: .running,
            totalTimeInterval: 30.5,
            endDate: Date.now.addingTimeInterval(25),
            remainingWhenNotRunning: 0,
            displayedRemainingTime: .seconds(25),
            label: "Preview"
        )
    )
    .frame(width: 100, height: 100)
}
