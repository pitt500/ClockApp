//
//  LockScreenTimerLiveActivityView.swift
//  ClockApp
//
//  Created by Pedro Rojas on 03/03/26.
//


import SwiftUI
import WidgetKit

struct LockScreenTimerLiveActivityView: View {
    let state: TimerAttributes.ContentState
    
    var body: some View {
        let provider = TimerLiveActivityProgressProvider(state: state)

        VStack(spacing: 8) {
            if let endDate = state.endDate {
                Text(
                    timerInterval: Date.now...endDate,
                    countsDown: true
                )
                .font(.system(size: 34, weight: .light, design: .rounded))
                .monospacedDigit()
            } else {
                Text(formattedRemainingTime(using: provider.snapshot, at: .now))
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .monospacedDigit()
            }
        }
        .activityBackgroundTint(Color.cyan)
        .activitySystemActionForegroundColor(Color.black)
    }

#warning("Fix time format")
    private func formattedRemainingTime(using snapshot: TimerProgressSnapshot, at date: Date) -> String {
        let seconds = max(0, Int(snapshot.remainingInterval(at: date)))

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
