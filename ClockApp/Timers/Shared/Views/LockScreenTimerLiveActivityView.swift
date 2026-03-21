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
    
    #warning("Fix this view later")
    var body: some View {
        VStack(spacing: 8) {
            if let timerInterval {
                Text(
                    timerInterval: timerInterval,
                    pauseTime: nil,
                    countsDown: true,
                    showsHours: showsHours
                )
                .font(.system(size: 34, weight: .light, design: .rounded))
                .monospacedDigit()
            } else {
                Text(formattedRemainingTime)
                    .font(.system(size: 34, weight: .light, design: .rounded))
                    .monospacedDigit()
            }
        }
        .activityBackgroundTint(Color.cyan)
        .activitySystemActionForegroundColor(Color.black)
    }

    #warning("Code duplicated")
    private var timerInterval: ClosedRange<Date>? {
        guard state.status == .running, let endDate = state.endDate else { return nil }
        let startDate = endDate.addingTimeInterval(-state.totalTimeInterval)
        return startDate...endDate
    }

    private var showsHours: Bool {
        let seconds = Int(max(0, state.totalTimeInterval))
        return seconds >= 3600
    }

    #warning("Fix format")
    private var formattedRemainingTime: String {
        let seconds = max(0, state.displayedRemainingTime.components.seconds)

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
