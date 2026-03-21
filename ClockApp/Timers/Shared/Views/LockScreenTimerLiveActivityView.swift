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
        VStack(spacing: 8) {
            if let timerInterval = state.runningTimeInterval {
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

    private var showsHours: Bool {
        let seconds = Int(max(0, state.totalTimeInterval))
        return seconds >= 3600
    }

    private var formattedRemainingTime: String {
        LiveActivityTimerFormatting.formattedDisplayTime(state.displayedRemainingTime)
    }
}
